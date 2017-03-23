$(function () {
  $('#events tfoot th').each(function () {
    $(this).html( '<p>検索: <input type="text" /></p>' );
  });
  var table = $('#events').DataTable({
    "lengthMenu": [[5, 10, 20, -1], [5, 10, 20, "ALL"]],
    "stateSave": true,
    "processing": true, // 処理中の表示
    "serverSide": true, // サーバサイドへ Ajax するか
    "ajax": "list", // Ajax の通信先
    "columns": [ //# 扱うカラムの指定
      { "data": "id" },
      { "data": "name" },
      { "data": "event_details" },
    ]
  });

  // Restore state
  var state = table.state.loaded();
  if (state) {
    table.columns().eq(0).each(function (colIdx) {
      var colSearch = state.columns[colIdx].search;
      if (colSearch) {
        $('input', table.column(colIdx).footer()).val(colSearch.search);
      }
    });
    table.draw();
  }

  // Apply the search
  table.columns().every(function () {
    var that = this;
    $('input', this.footer()).on('keyup change', function () {
      if (that.search() !== this.value) {
        that.search(this.value).draw();
      }
    });
  });
});