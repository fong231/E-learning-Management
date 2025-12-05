class PinMessage {
    async getPinMessage(type, ortherUserId = null) {
        if(type === 'project') {
            let response = await window.api.getPinMessage(projectId);
            if(response.success) {
                let data = response.data;
                
                if (data.length > 0) {
                    this.loadPinnedMessages(data);
                }
            }
        } else {
            let response = await window.api.getPinMessage(projectId, ortherUserId);
            if(response.success) {
                let data = response.data;
                
                if (data.length > 0) {
                    this.loadPinnedMessages(data);
                }
            }
        }
    }

    async scrollToMessage(messageId) {
        let messageElement;

        for (let i = 0; i < 10; i++) {
            messageElement = document.querySelector(`.message[data-message-id="${messageId}"]`);
            console.log(messageElement)
            if (!messageElement) {
                document.getElementById('chat-messages-list').scrollTop = 0;
                await loadMoreMessages();
            } else {
                break;
            }
        }

        if (!document.getElementById('pinned-list').classList.contains('hidden')) {
            this.togglePinnedList();
        }
        
        messageElement.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'center'
        });

        messageElement.classList.add('bg-blue-200', 'ring-4', 'ring-blue-300', 'transition-all');
        setTimeout(() => {
            messageElement.classList.remove('bg-blue-200', 'ring-4', 'ring-blue-300');
        }, 1500);
    }

    togglePinnedList() {
        const pinnedList = document.getElementById('pinned-list');
        const pinnedChevron = document.getElementById('pinned-chevron');
        
        if (pinnedList.classList.contains('hidden')) {
            pinnedList.classList.remove('hidden');
            pinnedChevron.setAttribute('data-lucide', 'chevron-up');
            pinnedChevron.classList.add('rotate-180');
            
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        } else {
            pinnedList.classList.add('hidden');
            pinnedChevron.setAttribute('data-lucide', 'chevron-down');
            pinnedChevron.classList.remove('rotate-180');
            
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        }
    }

    loadPinnedMessages(pinnedMessages) {
        const pinnedSection = document.getElementById('pinned-section');
        const pinnedList = document.getElementById('pinned-list');
        const pinnedCount = document.getElementById('pinned-count');

        if (!pinnedMessages || pinnedMessages.length === 0) {
            pinnedSection.classList.add('hidden');
            pinnedSection.classList.remove('flex');
            pinnedList.innerHTML = '';
            pinnedCount.textContent = 0;
            return;
        }

        let html = '';
        pinnedMessages.forEach(msg => {
            html += this.renderPinnedMessageHtml(msg);
        });

        pinnedList.innerHTML = html;
        pinnedCount.textContent = pinnedMessages.length;

        pinnedSection.classList.remove('hidden');
        pinnedSection.classList.add('flex');

        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
    }

    renderPinnedMessageHtml(message) {
        return `
            <div class="pinned-message p-2 bg-yellow-100 rounded-md shadow-sm text-xs text-gray-800 hover:bg-yellow-200 cursor-pointer flex justify-between items-center" data-message-id="${message.message_id}" onclick="window.pinMessage.scrollToMessage('${message.message_id}')">
                <span class="truncate font-medium">${message.sender.full_name}:</span>
                <span class="ml-2 truncate">${message.message}</span>
                <i data-lucide="chevrons-right" class="w-4 h-4 text-yellow-600 flex-shrink-0 ml-2"></i>
            </div>
        `;
    }   
}

window.pinMessage = new PinMessage();