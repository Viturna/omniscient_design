$('#openPopup').click(function() {
  $('#popup').css('display', 'flex'); // Affiche la popup en display:flex
});
$('#closePopupSave').click(function() {
  $('#popup').hide(); // Cache la popup
});
$('#saveToList').click(function() {
  var selectedList = $('#liste').val();
  alert("Enregistrer l'œuvre dans la liste : " + selectedList);
  $('#popup').hide();
});
