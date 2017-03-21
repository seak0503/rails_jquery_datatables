# rails jquery datatables

[ネタ元](http://jetglass.hatenablog.jp/entry/2015/05/27/172831)

# 準備

## Gemfile

```
gem 'kaminari'
gem 'jquery-datatables-rails', '~> 3.4.0'
```

## インストール

```
bin/bundle install
```

## generator からのインストール

```
$ rails generate jquery:datatables:install
  insert  app/assets/javascripts/application.js
  insert  app/assets/stylesheets/application.css
```

下記ファイルに下記内容が追加されていることを確認する。

```
$ less app/assets/javascripts/application.js
//= require dataTables/jquery.dataTables

$ less app/assets/stylesheets/application.css
*= require dataTables/jquery.dataTables
```

bootstrap 3 をインストール。

```
bundle exec rails generate jquery:datatables:install bootstrap3
      insert  app/assets/javascripts/application.js
      insert  app/assets/stylesheets/application.css
```

下記ファイルに下記内容が追加されていることを確認する。

```
$ less app/assets/javascripts/application.js
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap

$ less app/assets/stylesheets/application.css
*= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
```

本家の bootstrap 3 を配置する。

```
# 下記のようにファイルを配置する
app/assets/javascripts/bootstrap.min.js
app/assets/stylesheets/bootstrap.min.css
```

# テスト用アプリ作成

## テスト用アプリ概要

下記のDB構成のアプリを作成する

* イベント 1:N イベント詳細 
* イベント詳細 1:N 中間テーブル N:1 トピック

## テスト用アプリ実装

### rails g

```
bundle exec rails g scaffold Event name
bundle exec rails g model EventDetail detail event_id:integer
bundle exec rails g model Topic name
bundle exec rails g model EventDetailTopic event_detail_id:integer topic_id:integer
```

### マイグレーション

```
bundle exec rake db:migrate
```

### モデル作成

```
class Event < ActiveRecord::Base
  has_many :event_details
  accepts_nested_attributes_for :event_details
end

class EventDetail < ActiveRecord::Base
  belongs_to :event
  has_many :event_detail_topics
  has_many :topics, through: :event_detail_topics
  accepts_nested_attributes_for :topics
end

class EventDetailTopic < ActiveRecord::Base
  belongs_to :event_detail
  belongs_to :topic
end

class Topic < ActiveRecord::Base
  has_many :event_detail_topics
end
```

### コントローラ実装

* newメソッドで関連するEventDetailとTopicのbuildをする

```
# GET /events/new
def new
  @event = Event.new
  @event.event_details.build #追加
  @event.event_details.first.topics.build #追加
end
```

* event_paramsの修正

```
# 修正前
def event_params
  params.require(:event).permit(:name)
end

# 修正後
def event_params
  params.require(:event).permit(
    :name,
    event_details_attributes: [
      :id,
      :detail,
      topics_attributes: [:id, :name]
    ]
  )
end
```

### ビュー実装

* _form.html.erb

```
<div class="field">
  <%= f.label :name %><br>
  <%= f.text_field :name %>
  <%= f.fields_for :event_details do |df| %>
    <%= render partial: "event_detail_form", locals: {df: df } %>
  <% end %>
</div>
```

* _event_detail_form.html.erb

```
<div class="field">
  <%= df.label :detail %><br>
  <%= df.text_field :detail %>
  <%= df.fields_for :topics do |tf| %>
    <%= render partial: "topic_form", locals: {tf: tf } %>
  <% end %>
</div>
```

* _topic_form.html.erb

```
<div class="field">
  <%= tf.label :topicname %><br>
  <%= tf.text_field :name %>
</div>
```

### 新規作成画面の挙動確認

ここまでの作業で、`rails console`を立ち上げ、新規作成画面のフォームに適当に値を入力して「Create Event」ボタンを押すと、各モデルのリレーションを保った状態で値がDBに保存される。

新規作成ではコントローラーの create メソッドが呼ばれるので、ソースを見てみる。

```
def create
  @event = Event.new(event_params)
  ...
    if @event.save
   ...
```

ここで注目すべきは、 event_params には hoge_attributes が含まれているにも関わらず、 Event.new でよしなに関連するモデルを生成してくれること（もちろんリレーションされた状態）。
save メソッドを呼んで保存する際には、関連するモデルも一緒に保存される。

event_paramsの中身は下記のようなかんじ

```
"event"=>{
  "name"=>"event5", 
  "event_details_attributes"=>{
    "0"=>{
      "detail"=>"event5 detail", 
      "topics_attributes"=>{
        "0"=>{
          "name"=>"event5 topic"
        }
      }
    }
  }
}
```


### 更新画面の挙動確認

今度は編集画面で値を編集する。
適当に値を書き換えて「Update Event」ボタンを押下。

編集(更新)ではコントローラーの update メソッドが呼ばれるので、ソースを見てみる。

```
def update
  ...
    if @event.update(event_params)
   ...
```

update メソッドの引数として event_params(hoge_attributes を含む)を渡しても、 よしなに該当するレコードを更新してくれる。

なぜなら、viewに自動的にEventDetailとTopicの`:id`がhidden で設定され、パラメータにわたってくるため。

```
"event"=>{
  "name"=>"event5 edit", 
  "event_details_attributes"=>{
    "0"=>{
      "detail"=>"event5 detail edit", 
      "topics_attributes"=>{
        "0"=>{
          "name"=>"event5 topic edit", 
          "id"=>"5"
        }
      }, 
      "id"=>"5"
    }
  }
}
```

# jQeury DataTablesとの連動(Ajax)

## ルーティング

```
# config/routes.rb 一部抜粋
  resources :events do
    collection do #追加
      get :list #追加
    end #追加
  end
```

## コントローラ

list メソッドを実装。

`EventsDatatable`はパラメーターを受け取って、それに従った SQL を実行し、JSON 形式に変換するクラス。

```
# app/controllers/events_controller.rb 一部抜粋
  def list
    respond_to do |format|
      format.html
      format.json {render json: EventsDatatable.new(params) }
    end
  end
```

## ビュー

必要最低限の項目を作成。
あとは jQuery DataTables プラグインが色々な機能を足してくれる。

```
# app/views/events/list.html.erb を追加
<table id="events" class='table table-striped table-bordered'>
  <thead>
    <tr>
      <th>ID</th>
      <th>Name</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
```

## JSON変換クラス

一番大きい実装(モデルに実装できる内容だが、何も考えず切り分けた )。
受け取ったパラメーターから条件に合うデータを取得、結果を JSON 形式にする。

まずはAjax 通信で飛んでくるパラメーター。

```
{
  "draw" => "1", 
  # 今回の実装では columns 内 data  の項目しか使っていない
  # 項目毎に検索対象やソート対象にするか、とかのオプション指定ができると思われる
  "columns" => {
    "0" => {"data"=>"id", "name"=>"", "searchable"=>"true",
            "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}},
    "1" => {"data"=>"name", "name"=>"", "searchable"=>"true",
            "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}
  },
  # どのカラムを昇順・降順にするか
  "order"=>{"0"=>{"column"=>"0", "dir"=>"asc"}},
  # ページ数と1ページに取得する件数
  "start"=>"0", "length"=>"10", 
  # 検索キーワード
  "search"=>{"value"=>"hoge", "regex"=>"false"}, "_"=>"14328624114557"}
```

パラメータを解釈して、データを取得するクラス。

```
# app/datatables/events_datatable.rb 追加
# -*- coding: utf-8 -*-
#
class EventsDatatable
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  # jQuery DataTables へ渡すためのハッシュを作る
  # 補足：コントローラーの render json: で指定したオブジェクトに対して as_json が呼び出される
  def as_json(options = {})
    {
      recordsTotal: Event.count, # 取得件数
      recordsFiltered: events.total_count, # フィルター前の全件数
      data: events.as_json, # 表データ
    }
  end

  def events
    @events ||= fetch_events
  end

  # 検索条件や件数を指定してデータを取得
  def fetch_events
    Event.where(search_sql).order(order_sql).page(page).per(per)
  end

  # カラム情報を配列にする
  def columns
    return [] if params["columns"].blank?
    params["columns"].map{|_,v| v["data"]}
  end

  # 検索ワードが指定されたとき
  def search_sql
    return "" if params["search"]["value"].blank?
    search = params["search"]["value"]
    # name カラム固定の検索にしている
    # "name like '%hoge%'"のようにSQLの一部を作る
    "name like '%#{search}%'"
  end

  # ソート順
  def order_sql
    return "" if params["order"]["0"].blank?
    order_data = params["order"]["0"]
    order_column = columns[order_data["column"].to_i]
    # "id desc" のようにSQLの一部を作る
    "#{order_column} #{order_data["dir"]}"
  end

  # kaminari 向け、ページ数
  def page
    params["start"].to_i / per + 1
  end

  # kaminari 向け、1ページで取得する件数
  def per
    params["length"].to_i > 0 ? params["length"].to_i : 10
  end

end
```

## coffeescript

下記を追加。

```
# app/assets/javascripts/events.js.coffee
jQuery ->
  $('#events').dataTable
    "processing": true, # 処理中の表示
    "serverSide": true, # サーバサイドへ Ajax するか
    "ajax": "list", # Ajax の通信先
    "columns": [ # 扱うカラムの指定
      { "data": "id" },
      { "data": "name" },
    ]
```

## オートロード追加

追加した JSON 変換クラスをオートロードさせる。

```
# app/config/application.rb
...
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/datatables) # 追加
...
```

## 実装完了

以上で完了

## まとめ

jQuery DataTables プラグインを使うことで検索・ソート・ページ送りなどの機能をビュー側で実装する必要がなくなるので、手っ取り早く一覧画面を作りたいときにおすすめ。

今回の実装はほぼ初期設定だが、それでも十分だと感じた。

編集ボタンや削除ボタンの HTML を表データとして JSON にして返却すれば、 ボタンの設置も可能。

jQuery DataTables プラグインは高機能だと思われるので、 必要に応じてリファレンス読み込んで機能追加するといい。
Reference

新規追加・編集・削除も Ajax で動的にできるようだ。
https://editor.datatables.net/examples/simple/simple



