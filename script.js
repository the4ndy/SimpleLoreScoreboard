function changeNumber(numberId, increment) {
    let spanId = "number" + numberId;
    let numberSpan = document.getElementById(spanId);
    let currentNumber = parseInt(numberSpan.textContent);
    let newNumber = currentNumber + increment;

    if (newNumber < 0) {
        newNumber = 0;
    }

    numberSpan.textContent = newNumber;

    fetch('/updateNumber', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `numberId=${numberId}&newNumber=${newNumber}`,
    });
}

function updateScores() {
    fetch('/getNumbers')
        .then(response => response.json())
        .then(data => {
            document.getElementById('number1').textContent = data.number1;
            document.getElementById('number2').textContent = data.number2;
        });
}

window.onload = function() {
    updateScores(); // Initial update
    setInterval(updateScores, 2000); // Update every 2 seconds
};

function showResetPopover() {
    document.getElementById('resetPopover').classList.add('show');
}

function hideResetPopover() {
    document.getElementById('resetPopover').classList.remove('show');
}

function resetScores() {
    fetch('/resetScores', {
        method: 'POST',
    }).then(() => {
        updateScores(); // Update scores after reset
        hideResetPopover();
    });
}

const fullscreenBtn = document.getElementById('fullscreenBtn');
const elementToFullscreen = document.documentElement; // The entire HTML document

fullscreenBtn.addEventListener('click', () => {
  if (!document.fullscreenElement) {
    if (elementToFullscreen.requestFullscreen) {
      elementToFullscreen.requestFullscreen();
    } else if (elementToFullscreen.mozRequestFullScreen) {
      elementToFullscreen.mozRequestFullScreen();
    } else if (elementToFullscreen.webkitRequestFullscreen) {
      elementToFullscreen.webkitRequestFullscreen();
    } else if (elementToFullscreen.msRequestFullscreen) {
      elementToFullscreen.msRequestFullscreen();
    }
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen();
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen();
    }
  }
});