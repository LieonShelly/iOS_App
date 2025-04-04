document.addEventListener('DOMContentLoaded', function() {
    // Get DOM elements
    const confirmButton = document.getElementById('confirm-button');
    const confirmCountElement = document.getElementById('confirm-count');
    const countdownContainer = document.getElementById('countdown-container');
    const countdownElement = document.getElementById('countdown');
    const statsButton = document.getElementById('stats-button');
    
    // Initialize variables
    let confirmCount = parseInt(localStorage.getItem('confirmCount')) || 0;
    let lastConfirmTime = parseInt(localStorage.getItem('lastConfirmTime')) || 0;
    let countdownInterval;
    
    // Update UI with stored values
    updateConfirmCount();
    checkCountdown();
    
    // Event listeners
    confirmButton.addEventListener('click', handleConfirm);
    statsButton.addEventListener('click', navigateToStats);
    
    // Functions
    function handleConfirm() {
        const currentTime = Date.now();
        const timeSinceLastConfirm = currentTime - lastConfirmTime;
        
        // Check if enough time has passed since last confirmation (5 minutes)
        if (timeSinceLastConfirm < 5 * 60 * 1000) {
            alert('请等待倒计时结束后再确认');
            return;
        }
        
        // Update confirmation count and time
        confirmCount++;
        lastConfirmTime = currentTime;
        
        // Save to localStorage
        localStorage.setItem('confirmCount', confirmCount);
        localStorage.setItem('lastConfirmTime', lastConfirmTime);
        
        // Update UI
        updateConfirmCount();
        startCountdown();
        
        // Navigate to confirmation page
        window.location.href = 'confirm.html';
    }
    
    function updateConfirmCount() {
        confirmCountElement.textContent = confirmCount;
    }
    
    function startCountdown() {
        // Show countdown container
        countdownContainer.classList.remove('hidden');
        
        // Clear any existing interval
        if (countdownInterval) {
            clearInterval(countdownInterval);
        }
        
        // Start countdown from 5 minutes
        let remainingSeconds = 5 * 60;
        countdownElement.textContent = remainingSeconds;
        
        countdownInterval = setInterval(() => {
            remainingSeconds--;
            countdownElement.textContent = remainingSeconds;
            
            if (remainingSeconds <= 0) {
                clearInterval(countdownInterval);
                countdownContainer.classList.add('hidden');
            }
        }, 1000);
    }
    
    function checkCountdown() {
        const currentTime = Date.now();
        const timeSinceLastConfirm = currentTime - lastConfirmTime;
        
        if (timeSinceLastConfirm < 5 * 60 * 1000) {
            // Calculate remaining seconds
            const remainingSeconds = Math.ceil((5 * 60 * 1000 - timeSinceLastConfirm) / 1000);
            countdownElement.textContent = remainingSeconds;
            countdownContainer.classList.remove('hidden');
            
            // Start countdown from remaining time
            countdownInterval = setInterval(() => {
                const updatedTime = Date.now();
                const updatedTimeSinceLastConfirm = updatedTime - lastConfirmTime;
                const updatedRemainingSeconds = Math.ceil((5 * 60 * 1000 - updatedTimeSinceLastConfirm) / 1000);
                
                if (updatedRemainingSeconds <= 0) {
                    clearInterval(countdownInterval);
                    countdownContainer.classList.add('hidden');
                } else {
                    countdownElement.textContent = updatedRemainingSeconds;
                }
            }, 1000);
        } else {
            countdownContainer.classList.add('hidden');
        }
    }
    
    function navigateToStats() {
        window.location.href = 'stats.html';
    }
}); 