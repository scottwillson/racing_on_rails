jQuery(document).ready(function() {
  var currentPage = jQuery('input[name=current_page]').val();
  jQuery('a.show_post').prop('href', function(index, oldPropertyValue) {
    return oldPropertyValue + '?page=' + currentPage;
  });
});
