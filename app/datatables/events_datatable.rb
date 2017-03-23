class EventsDatatable
  attr_accessor :params

  def initialize(params)
    @params = params
    @rel = Event.joins(:event_details)
  end

  # jQuery DataTables へ渡すためのハッシュを作る
  # 補足：コントローラーの render json: で指定したオブジェクトに対して as_json が呼び出される
  def as_json(options = {})
    data = []
    search.each do |e|
      event_details = e.event_details.map(&:detail).join(', ')
      data << {"id" => e.id, "name" => e.name, "event_details" => event_details}
    end
    {
      recordsTotal: Event.count, # 取得件数
      recordsFiltered: search.total_count, # フィルター前の全件数
      data: data, # 表データ
    }
  end

  private
  def search
    search_sql
    order_sql
    @rel.page(page).per(per)
  end

  # カラム情報を配列にする
  def columns
    return [] if params["columns"].blank?
    params["columns"].map{|_,v| v["data"]}
  end

  # 検索ワードが指定されたとき
  def search_sql
    params["columns"].each do |key, value|
      search_column = columns[key.to_i]
      search_value = value["search"]["value"]
      @rel = @rel.where("events.id LIKE ?", "%#{search_value}%") if (search_column == "id") && search_value.present?
      @rel = @rel.where("events.name LIKE ?", "%#{search_value}%") if (search_column == "name") && search_value.present?
      if (search_column == "event_details") && search_value.present?
        @rel = @rel.where("event_details.detail LIKE ?", "%#{search_value}%")
      end
    end
  end

  # ソート順
  def order_sql
    if params["order"]["0"].present?
      order_data = params["order"]["0"]
      order_column = columns[order_data["column"].to_i]
      @rel = @rel.order("events.id #{order_data["dir"]}") if order_column == "id"
      @rel = @rel.order("events.name #{order_data["dir"]}") if order_column == "name"
      @rel = @rel.order("event_details.detail #{order_data["dir"]}") if order_column == "event_details"
    end
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