jQuery ->
  $('#events').dataTable
    "processing": true, # 処理中の表示
    "serverSide": true, # サーバサイドへ Ajax するか
    "ajax": "list", # Ajax の通信先
    "columns": [ # 扱うカラムの指定
      { "data": "id" },
      { "data": "name" },
    ]