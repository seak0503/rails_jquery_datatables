$(function () {
  $('#events tfoot th').each(function () {
    var $this = $(this),
      title = $this.text();
    $this.html( '<input type="text" placeholder="Search '+title+'" />' );
  });
  var table = $('#events').DataTable({
    "processing": true, // 処理中の表示
    "serverSide": true, // サーバサイドへ Ajax するか
    "ajax": "list", // Ajax の通信先
    "columns": [ //# 扱うカラムの指定
      { "data": "id" },
      { "data": "name" },
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