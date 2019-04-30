// Turbolinks prevents document ready so use this instead
$( document ).on('turbolinks:load', function() {

  // See slider in the bottom script of views/resources/new_manifest.html.erb
    var idsInOrder = [];

    // Update the order of compound ids with quotation marks and separated by commas ("1-385","1-386")
    function updateIdsOrder() {
      idsInOrder = [];
      // console.log("Sorted!");
      $('.panel-heading').each(function(){
        idsInOrder.push($(this).attr('id'));
      });
      var quotedIds = '"' + idsInOrder.join('","') + '"';
      $('#resources_upload_compound_ids').val(quotedIds);
    }

    var sortable = new Sortable(items, {
        ghostClass: 'ghost',
        sort: true,
        onSort: function() {
          updateIdsOrder();
        }
        //disabled: false
    });

    // var first = true;

    function addPanel() {
      // Grab the appropriate title from the link clicked
      var title = $(this).parents('tr').find('.title').text();//.text();
      // Add compound ID to text box
      var doc = $(this).parents('tr').find('.doc-id > span').text();
      var docSpan = '<span class="doc-span">' + doc + '</span>';

      panelContent =
      '<li>' +
      '<div class="dd3-content panel panel-default page-admin">' +
          '<div class="dd-handle dd3-handle"></div>' +
          '<div class="panel-heading" id="' + doc + '">' + docSpan + title +
            '<a class="btn btn-link remove-id">' + '<span class="glyphicon glyphicon-remove remove-button" aria-hidden="true"></span>' +
            '</a>' +
          '</div>' +
          '</div>' +
      '</div>' +
      '</li>'
      $('.panel-group > ol').append(panelContent);
      updateIdsOrder();
    }

    // $('#results').on('click', '.add-doc-id', addPanel);

    // // Add ID to compound ids list
    // $('#results').on('click', '.add-doc-id', function(){
    //   // Grab the appropriate title from the link clicked
    //   var title = $(this).parents('tr').find('.title').text();//.text();
    //   // Add compound ID to text box
    //   var doc = $(this).parents('tr').find('.doc-id > span').text();
    //   var docSpan = '<span class="doc-span">' + doc + '</span>';
    //
    //   panelContent =
    //   '<li>' +
    //   '<div class="dd3-content panel panel-default page-admin">' +
    //       '<div class="dd-handle dd3-handle"></div>' +
    //       '<div class="panel-heading" id="' + doc + '">' + docSpan + title +
    //         '<a class="btn btn-link remove-id">' + '<span class="glyphicon glyphicon-remove remove-button" aria-hidden="true"></span>' +
    //         '</a>' +
    //       '</div>' +
    //       '</div>' +
    //   '</div>' +
    //   '</li>'
    //   $('.panel-group > ol').append(panelContent);
    //   updateIdsOrder();
    // }); // function

    // Remove a panel and its ID
    $(document).on('click', '.remove-id', function(){
        $(this).parents('.dd3-content.panel').remove();
        updateIdsOrder();
    });



});
