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
    query = ""
    params["columns"].each do |key, value|
      search_column = columns[key.to_i]
      search_value = value["search"]["value"]
      if key.to_i == 0
        query += "#{search_column} like '%#{search_value}%'" if search_value.present?
      elsif (key.to_i >= 1) && (query.blank?)
        query += "#{search_column} like '%#{search_value}%'" if search_value.present?
      else
        query += " and #{search_column} like '%#{search_value}%'" if search_value.present?
      end
    end
    return query
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