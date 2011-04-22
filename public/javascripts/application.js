// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

  //$('#tags').tagsInput();
  //alert("hola");

$(document).ready(function () {
  $('input.tags').tagsInput({
    'unique':true,
    'delimiter':" ",
    'defaultText':'add a scope',
    'height':'78px',
    'width':'295px'
  });  
});

