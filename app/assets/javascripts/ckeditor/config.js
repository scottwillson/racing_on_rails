CKEDITOR.editorConfig = function( config )
{
  config.allowedContent = true;

  config.toolbar = [
    { name: 'undo', groups: [ 'undo' ], items: [ 'Undo', 'Redo' ] },
    { name: 'links', items: [ 'Link', 'Unlink' ] },
    { name: 'insert', items: [ 'Image', 'Table', 'HorizontalRule' ] },
    { name: 'paragraph', groups: [ 'list' ], items: [ 'NumberedList', 'BulletedList' ] },
    { name: 'styles', items: [ 'Format' ] },
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Maximize' ] }
  ];
};
