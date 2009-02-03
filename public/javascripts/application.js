function toggle_disclosure(e) {
  var id = this;
  var disclosureTriangle = $('disclosure_' + id);
  if (disclosureTriangle.hasClassName("collapsed")) {
    expandDisclosure(id);
  }
  else {
    disclosureTriangle.removeClassName("expanded");
    disclosureTriangle.addClassName("collapsed");
    $('category_' + id + "_children").innerHTML = "";
  }
}

function expandDisclosure(id) {
  var disclosureTriangle = $('disclosure_' + id);
  disclosureTriangle.removeClassName("collapsed");
  disclosureTriangle.removeClassName("expanded");
  disclosureTriangle.addClassName("loading");
  new Ajax.Updater('category_' + id + "_children", "/admin/categories/" + id + "/children", {
                    method:"get", 
                    asynchronous:true, 
                    evalScripts:true,
                    onComplete: function(transport) {
                      disclosureTriangle.removeClassName("loading");
                      disclosureTriangle.addClassName("expanded");
                    }
                  });
}

function resizeRelativeToWindow() {
  var id = "category_root";
  var document_viewport_height = document.viewport.getHeight();
  var table_container = $(id);
  if (document_viewport_height < 100) {
    table_container.setStyle({ height: 'auto' });
  }
  else {
    var newHeight = table_container.getHeight() + (document_viewport_height - $('frame').getHeight()) - 56;
    if (newHeight < 50) newHeight = 50;
    table_container.setStyle({ height: newHeight + 'px' });
  }  
}

function fixTableColumnWidths(table_id) {
  $$('#' + table_id + ' th').each(function(th, index){
    th.setStyle({width: (th.getWidth() - 8) + 'px'});
  });  
}

function resetTableColumnWidths(table_id) {
  $$('#' + table_id + ' th').each(function(th, index){
    th.setStyle({width: '100%'});
  });
  fixTableColumnWidths(table_id);
}

function restripeTable(id) {
  index = 0;
  $A($(id).rows).each(function(row) {
    if (row.className == 'even' || row.className == 'odd') {
      if (index % 2 == 0) {
        row.className = 'even';
      }
      else {
        row.className = 'odd';
      }
      index = index + 1;
    }
  });
}

function flash(key, message) {
  $('info').hide();
  $('notice').hide();
  $('warn').hide();
  
  $(key + '_span').update(message);
  $(key).show();
}
