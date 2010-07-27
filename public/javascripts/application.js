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
  $(document).ready(function() {
    var ths = $('#' + table_id + ' th');

    var thWidths = ths.map(function(index, th) {
      return $(th).width() - Number($(th).css('paddingLeft').replace('px', ''));
    }).get();

    ths.each(function(th, index) {
      $(th).css('width', (thWidths[index] - 2) + 'px');
    });
  });
}

function resetTableColumnWidths(table_id) {
  $('#' + table_id + ' th').each(function(index, th){
    $(th).css('width', 'default');
  });
  fixTableColumnWidths(table_id);
}

function restripeTable(id) {
  var startIndex = 0;
  if ($('#' + id + ' tr th').length > 0) {
    startIndex = 1;
  }
  
  $('#' + id + ' tr').each(function(index, tr) {
    var row = $(tr);
    if (index >= startIndex && (row.hasClass('even') || row.hasClass('odd'))) {
      row.removeClass('even');
      row.removeClass('odd');
      if ((index + startIndex) % 2 == 0) {
        row.addClass('even');
      }
      else {
        row.addClass('odd');
      }
    }
  });
}

function flash(key, message) {
  if ($('#info').length > 0) { $('#info').hide() }
  if ($('#notice').length > 0) { $('#notice').hide() }
  if ($('#warn').length > 0) { $('#warn').hide() }
  
  $('#' + key + '_span').html(message);
  $('#' + key).show();
}

function pinTo100PctVertical(id) {
  $(document).ready(function() {
    sizeTo100PctVertical(id);
  });

  Event.observe(window, 'resize', function() {
    sizeTo100PctVertical(id);
  });
}

function sizeTo100PctVertical(id) {
  newHeight = ($(id).getHeight() + (document.viewport.getHeight() - $('body').offsetHeight)) - 16;
  $(id).setStyle( { height: newHeight + 'px' })
}

function autoComplete(model, attribute, path) {
  $(document).ready(function() {
    $('#' + attribute + '_auto_complete').autocomplete({
      delay: 200,
      minLength: 3,
      source: path,
      focus: function(event, ui) {
        $('#promoter_auto_complete').val(ui.item.person.first_name + ' ' + ui.item.person.last_name);
        return false;
      },
      select: function(event, ui) {
        $('#promoter_auto_complete').val(ui.item.person.first_name + ' ' + ui.item.person.last_name);
        $('#event_promoter_id').val(ui.item.person.id);
        return false;
      }
    })
    .data( "autocomplete" )
    ._renderItem = function(ul, item) {
        var description = [];
        if (item.person.team !== undefined && item.person.team.name !== undefined) {
          description.push(item.person.team.name);
        }
        if (item.person.city !== undefined) {
          description.push(item.person.city);
        }
        if (item.person.state !== undefined) {
          description.push(item.person.state);
        }
        
        return $('<li id="' + item.person.id + '"></li>')
          .data( "item.autocomplete", item )
          .append('<a>' + item.person.first_name + ' ' + item.person.last_name + '<div class="informal">' + description + "</div></a>")
          .appendTo( ul );
      };
    ;
  });  
}    
