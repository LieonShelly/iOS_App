document.addEventListener('DOMContentLoaded', function() {
    // Get DOM elements
    const todayConfirmCount = document.getElementById('today-confirm-count');
    const challengeStatus = document.getElementById('challenge-status');
    const statusText = challengeStatus.querySelector('.status-text');
    const progressPercentage = document.getElementById('progress-percentage');
    const backHomeButton = document.getElementById('back-home');
    
    // Initialize variables
    let weeklyData = JSON.parse(localStorage.getItem('weeklyData')) || [];
    let todayCount = parseInt(localStorage.getItem('confirmCount')) || 0;
    
    // Update UI
    updateTodayCount();
    updateChallengeStatus();
    updateWeeklyChart();
    updateProgressFeedback();
    
    // Event listeners
    backHomeButton.addEventListener('click', navigateToHome);
    
    // Functions
    function updateTodayCount() {
        todayConfirmCount.textContent = todayCount;
    }
    
    function updateChallengeStatus() {
        // Challenge is successful if today's count is 1 or less
        if (todayCount <= 1) {
            challengeStatus.style.backgroundColor = '#e6ffe6';
            challengeStatus.style.color = '#4caf50';
            statusText.textContent = '已完成';
        } else {
            challengeStatus.style.backgroundColor = '#fff3e0';
            challengeStatus.style.color = '#ff9800';
            statusText.textContent = '进行中';
        }
    }
    
    function updateWeeklyChart() {
        // Get the canvas element
        const ctx = document.getElementById('weekly-chart').getContext('2d');
        
        // Generate labels for the last 7 days
        const labels = [];
        for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            labels.push(date.toLocaleDateString('zh-CN', { weekday: 'short' }));
        }
        
        // If we don't have enough data, generate some sample data
        if (weeklyData.length < 7) {
            weeklyData = [];
            for (let i = 0; i < 7; i++) {
                weeklyData.push(Math.floor(Math.random() * 5) + 1);
            }
            // Save today's count as the last entry
            weeklyData[6] = todayCount;
            localStorage.setItem('weeklyData', JSON.stringify(weeklyData));
        }
        
        // Create the chart
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: '确认次数',
                    data: weeklyData,
                    backgroundColor: 'rgba(74, 144, 226, 0.2)',
                    borderColor: 'rgba(74, 144, 226, 1)',
                    borderWidth: 2,
                    tension: 0.3,
                    pointBackgroundColor: 'rgba(74, 144, 226, 1)',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    }
    
    function updateProgressFeedback() {
        // Calculate progress compared to last week
        if (weeklyData.length >= 14) {
            const thisWeekAvg = weeklyData.slice(-7).reduce((a, b) => a + b, 0) / 7;
            const lastWeekAvg = weeklyData.slice(-14, -7).reduce((a, b) => a + b, 0) / 7;
            
            if (lastWeekAvg > 0) {
                const reductionPercentage = Math.round((1 - thisWeekAvg / lastWeekAvg) * 100);
                progressPercentage.textContent = reductionPercentage;
                
                // Update message based on progress
                const progressMessage = document.getElementById('progress-message');
                if (reductionPercentage > 0) {
                    progressMessage.textContent = `你比上周减少了 ${reductionPercentage}% 的确认次数，继续加油！`;
                } else if (reductionPercentage < 0) {
                    progressMessage.textContent = `你比上周增加了 ${Math.abs(reductionPercentage)}% 的确认次数，请继续努力！`;
                } else {
                    progressMessage.textContent = '你的确认次数与上周相同，请继续努力减少！';
                }
            }
        }
    }
    
    function navigateToHome() {
        window.location.href = 'index.html';
    }
}); 