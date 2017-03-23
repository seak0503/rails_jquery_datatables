$(function () {
  $('#events tfoot th').each(function () {
    $(this).html( '<p>検索: <input type="text" /></p>' );
  });
  var table = $('#events').DataTable({
    "lengthMenu": [[5, 10, 20, -1], [5, 10, 20, "ALL"]],
    "processing": true, // 処理中の表示
    "serverSide": true, // サーバサイドへ Ajax するか
    "ajax": "list", // Ajax の通信先
    "columns": [ //# 扱うカラムの指定
      { "data": "id" },
      { "data": "name" },
      { "data": "event_details" },
    ]
  });
  table.columns().every(function () {
    var that = this;
    $('input', this.footer()).on('keyup change', function () {
      if (that.search() !== this.value) {
        that.search(this.value).draw();
      }
    });
  });
});