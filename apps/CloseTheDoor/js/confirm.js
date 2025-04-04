document.addEventListener('DOMContentLoaded', function() {
    // Get DOM elements
    const confirmationCountdown = document.getElementById('confirmation-countdown');
    const takePhotoButton = document.getElementById('take-photo');
    const photoPreview = document.getElementById('photo-preview');
    const lastPhoto = document.getElementById('last-photo');
    const playAudioButton = document.getElementById('play-audio');
    const confirmationAudio = document.getElementById('confirmation-audio');
    const backHomeButton = document.getElementById('back-home');
    
    // Initialize variables
    let countdownInterval;
    let hasViewedPhoto = false;
    
    // Start countdown
    startConfirmationCountdown();
    
    // Event listeners
    takePhotoButton.addEventListener('click', handlePhotoCapture);
    playAudioButton.addEventListener('click', playAudioMessage);
    backHomeButton.addEventListener('click', navigateToHome);
    
    // Functions
    function startConfirmationCountdown() {
        let remainingSeconds = 10;
        confirmationCountdown.textContent = remainingSeconds;
        
        countdownInterval = setInterval(() => {
            remainingSeconds--;
            confirmationCountdown.textContent = remainingSeconds;
            
            if (remainingSeconds <= 0) {
                clearInterval(countdownInterval);
                // Optionally navigate back to home after countdown
                // setTimeout(navigateToHome, 1000);
            }
        }, 1000);
    }
    
    function handlePhotoCapture() {
        // Check if device has camera access
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            alert('您的设备不支持拍照功能');
            return;
        }
        
        // Request camera access
        navigator.mediaDevices.getUserMedia({ video: true })
            .then(function(stream) {
                // Create video element to capture frame
                const video = document.createElement('video');
                video.srcObject = stream;
                video.play();
                
                // Create canvas to draw video frame
                const canvas = document.createElement('canvas');
                canvas.width = video.videoWidth;
                canvas.height = video.videoHeight;
                
                // Draw video frame to canvas after a short delay to ensure video is playing
                setTimeout(() => {
                    const context = canvas.getContext('2d');
                    context.drawImage(video, 0, 0, canvas.width, canvas.height);
                    
                    // Convert canvas to data URL
                    const photoData = canvas.toDataURL('image/jpeg');
                    
                    // Save photo to localStorage
                    localStorage.setItem('lastDoorPhoto', photoData);
                    
                    // Display photo
                    lastPhoto.src = photoData;
                    photoPreview.classList.remove('hidden');
                    
                    // Stop all tracks
                    stream.getTracks().forEach(track => track.stop());
                    
                    // Hide take photo button after capturing
                    takePhotoButton.style.display = 'none';
                }, 500);
            })
            .catch(function(error) {
                console.error('Error accessing camera:', error);
                alert('无法访问相机，请检查权限设置');
            });
    }
    
    function playAudioMessage() {
        // Check if audio is loaded
        if (confirmationAudio.readyState >= 2) {
            confirmationAudio.play()
                .catch(error => {
                    console.error('Error playing audio:', error);
                    alert('无法播放音频，请检查设备设置');
                });
        } else {
            alert('音频尚未加载完成，请稍后再试');
        }
    }
    
    function navigateToHome() {
        window.location.href = 'index.html';
    }
    
    // Check if there's a saved photo and display it
    const savedPhoto = localStorage.getItem('lastDoorPhoto');
    if (savedPhoto) {
        lastPhoto.src = savedPhoto;
        photoPreview.classList.remove('hidden');
        takePhotoButton.style.display = 'none';
    }
}); 