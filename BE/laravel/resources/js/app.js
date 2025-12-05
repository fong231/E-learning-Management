import './bootstrap';
import '../../public/js/api-client';
import '../../public/js/pin-message';

import Echo from 'laravel-echo';
import Pusher from 'pusher-js';
let token = await window.api.getToken();
window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_REVERB_APP_KEY,
    cluster: "mt1",
    wsHost: import.meta.env.VITE_REVERB_HOST,
    wsPort: import.meta.env.VITE_REVERB_PORT,
    wssPort: import.meta.env.VITE_REVERB_PORT,
    forceTLS: (import.meta.env.VITE_REVERB_SCHEME ?? 'https') === 'https',
    enabledTransports: ['ws', 'wss'],
    authEndpoint: '/broadcasting/auth',
    auth: {
        headers: {
            'Authorization': `Bearer ${token}`,
        },
    },
});