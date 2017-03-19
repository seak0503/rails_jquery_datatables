# rails jquery datatables

# 準備


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




