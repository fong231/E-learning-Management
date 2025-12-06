<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Successful - ProjectFlow</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .success-animation { animation: slideIn 0.5s ease-out; }
        @keyframes slideIn {
            0% { transform: translateY(20px); opacity: 0; }
            100% { transform: translateY(0); opacity: 1; }
        }
    </style>
</head>
<body class="bg-gray-50 h-screen flex flex-col justify-center items-center px-4">

    <!-- Main Card -->
    <div class="bg-white p-8 rounded-2xl shadow-xl max-w-md w-full text-center success-animation border border-gray-100">
        
        <!-- Icon Circle -->
        <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-indigo-100 mb-6">
            <i data-lucide="shield-check" class="h-10 w-10 text-indigo-600"></i>
        </div>

        <!-- Content -->
        <h1 class="text-2xl font-bold text-gray-900 mb-3">Password Successfully Reset</h1>
        
        <p class="text-gray-600 mb-8 leading-relaxed">
            Your password has been securely updated. You can now use your new password to log in to the system immediately.
        </p>

        <!-- Action Button -->
        <a href="{{ route('login') }}" class="block w-full bg-gray-900 hover:bg-gray-800 text-white font-semibold py-3 px-4 rounded-lg transition duration-200 shadow-md hover:shadow-lg flex items-center justify-center">
            <i data-lucide="log-in" class="w-5 h-5 mr-2"></i>
            Log in Now
        </a>

        <!-- Security Note -->
        <div class="mt-6 bg-yellow-50 p-3 rounded-lg border border-yellow-100">
            <div class="flex items-start">
                <i data-lucide="info" class="w-4 h-4 text-yellow-600 mt-0.5 mr-2 flex-shrink-0"></i>
                <p class="text-xs text-yellow-700 text-left">
                    If you did not make this change, please contact support immediately to lock your account.
                </p>
            </div>
        </div>
    </div>

    <!-- Branding Footer -->
    <div class="mt-8 text-center">
        <p class="text-sm text-gray-400">&copy; {{ date('Y') }} ProjectFlow System</p>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>