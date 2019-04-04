// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//
// Required by Blacklight
//= require jquery
//= require blacklight/blacklight
//
//= require mirador
//= require annotot/annotot_endpoint
//= require markerclusterer

//= require blacklight/checkbox_submit
//= require_tree .


// Turbolinks prevents document ready so use this instead
$( document ).on('turbolinks:load', function() {
    var first = true;
    // Populate form with doc-ids
    $('#results').on('click', '.add-doc-id', function(){
      var doc = $(this).parents('tr').find('.doc-id > span').text();
      if (first == true) {
        $('#resources_upload_compound_ids').val($('#resources_upload_compound_ids').val() + "\"" + doc + "\"");
        first = false;
      }
      else {
        // Add comma
        $('#resources_upload_compound_ids').val($('#resources_upload_compound_ids').val() + ", \"" + doc + "\"");
      }
    });
});
