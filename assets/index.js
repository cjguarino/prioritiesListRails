
function priorityIndexReady(){
  var url_length = window.location.href.length
  if (url_length > 53) {
    var id = window.location.href.substring(67, url_length)
    priorityShowHideComments(id);
  }
}

function priorityShowHideComments(id) {
  var div = '#priorityCommentsDiv' + id;
  var $button = '#priorityCommentsButton' + id;
  if ( $(div).css("display") == "none" ) {
    $(div).css("display", "block");
  } else {
    $(div).css("display", "none");
  }
}

$(document).scroll(function() {
  var y = $(this).scrollTop();
  if (y > 30) {
    $('.priorityMenu').css('transform','translateY(-40px)');
  } else {
    $('.priorityMenu').css('transform','translateY(0px)');
  }
});

$(document).on('click','.prioritiesOrganizeButton', function() {
  var confirmation = confirm("Organize Priority Numbers starting from 1?")
  return confirmation;
});

$(document).on('click','.prioritiesDirLink', function() {
  var id = this.id.substring(15, this.id.length)
  window.location.href = '#priority_list_' + id; 
  priorityShowHideComments(id);
});

$(document).on('click','.prioritiesBackToTop', function() {
  window.location.href = '#'
});

$( document ).on('click','.newPriorityButton', function () {
  $('.newPriorityDiv').toggle();
});

$( document ).on('click','.priorityCommentsButton', function () {
  var id = this.id.substring(22,this.id.length);
  priorityShowHideComments(id);
});

$( document ).on('click', '.priorityListLink', function () {
  var id = this.id.substring(26,31);
  var indexSelector = '#priority_list_' + id;
  var updateSelector = '#priority_update_list_' + id;
  if ( $(updateSelector).css('display') == 'none' ){
    $(updateSelector).show();
    $(indexSelector).hide();
  } else {
    $(updateSelector).hide();
    $(indexSelector).show();
  }
});

$( document ).on('click','.priorityListDelete', function() {
  var title = this.id.substring(6,this.id.length)
  var deleteConfirm = confirm("Are you sure you want to delete " + title + " ?")
  return deleteConfirm; 
});

$( document ).on('click','.priorityListCompleteBtn', function() {
  var title = this.id.substring(8,this.id.length)
  var deleteConfirm = confirm("Mark " + title + " as complete? Comments, status, and priority number will not transfer over.")
  return deleteConfirm;
});

