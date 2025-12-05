<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - ProjectFlow</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-gray-50 h-screen flex justify-center items-center px-4">

    <!-- Main Card Container -->
    <div class="bg-white p-8 sm:p-10 rounded-2xl shadow-2xl max-w-md w-full border border-gray-100">
        
        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-3xl font-extrabold text-gray-900 mb-2">Forgot Password</h1>
            <p class="text-gray-500">Please enter your email to recover your account</p>
        </div>

        <!-- 1. Recovery Form (Initial State) -->
        <div id="recovery-form" class="transition duration-300">
            <form id="forgot-password-form">
                <!-- Email Field -->
                <div class="mb-8">
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                    <div class="relative">
                        <input 
                            type="email" 
                            id="email" 
                            name="email" 
                            required 
                            placeholder="user@example.com"
                            class="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm transition duration-150"
                        >
                        <i data-lucide="mail" class="absolute right-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400"></i>
                    </div>
                </div>

                <!-- Submit Button -->
                <button 
                    type="submit" 
                    class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-md text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-200 transform hover:-translate-y-0.5"
                >
                    <i data-lucide="send" class="w-5 h-5 mr-2"></i>
                    Confirm
                </button>
            </form>
        </div>

        <!-- 2. Success Message (Hidden by default) -->
        <div id="success-message" class="hidden text-center transition duration-300">
            <!-- Icon Circle -->
            <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100 mb-6">
                <i data-lucide="check-circle" class="h-10 w-10 text-green-600"></i>
            </div>
            
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Recovery Link Sent!</h2>
            
            <p class="text-gray-600 mb-8 leading-relaxed">
                A password recovery link has been sent to your email. Please check your inbox (or spam folder).
            </p>

            <a href="{{ route('login') }}" class="inline-flex items-center justify-center py-2 px-4 text-sm font-medium text-indigo-600 hover:text-indigo-500 transition duration-150">
                <span class="mr-1">&larr;</span> Back to Login
            </a>
        </div>

        <!-- Back to Login Link for Form State -->
        <div id="back-link-form" class="mt-6 text-center">
            <a href="/login" class="text-sm font-medium text-gray-500 hover:text-indigo-600 transition duration-150">
                Back to Login
            </a>
        </div>
    </div>
    
    <!-- Branding Footer -->
    <div class="absolute bottom-4 text-center">
        <p class="text-sm text-gray-400">&copy; {{ date('Y') }} ProjectFlow System</p>
    </div>

    <script>
        // Initialize Lucide icons
        lucide.createIcons();

        document.getElementById('forgot-password-form').addEventListener('submit', function(e) {
            e.preventDefault(); // Prevent actual form submission (backend needed)
            
            // Hide the form
            document.getElementById('recovery-form').classList.add('hidden');
            document.getElementById('back-link-form').classList.add('hidden');

            // Show the success message
            const successMessage = document.getElementById('success-message');
            successMessage.classList.remove('hidden');
            
            // In a real environment, after the backend successfully sends the email, 
            // you would redirect the user to this page or display the message.
            fetch('http://localhost:80/api/send-reset-password-email', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    email: document.getElementById('email').value,
                }),
            })
        });
    </script>
</body>
</html>