var alertDiv = document.getElementById("alert");

var countdownDuration = 5000;

function closeAlert() {
  alertDiv.style.opacity = "0";
  setTimeout(function(){ alertDiv.style.display = "none"; }, 600);
}

if (alertDiv) {
  var progressBar = document.getElementById("progress-bar");
  var width = 0;
  var interval = setInterval(function() {
    width += 100 / (countdownDuration / 100);
    progressBar.style.width = width + '%';
    if (width >= 100) {
      clearInterval(interval);
      closeAlert();
    }
  }, 100);

  var close = document.getElementsByClassName("closebtn");
  for (var i = 0; i < close.length; i++) {
    close[i].onclick = function() {
      clearInterval(interval);
      closeAlert();
    }
  }
}
