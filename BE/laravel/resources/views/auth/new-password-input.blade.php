<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set New Password - ProjectFlow</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-gray-50 h-screen flex justify-center items-center px-4">

    <!-- Main Card Container -->
    <div class="bg-white p-8 sm:p-10 rounded-2xl shadow-2xl max-w-md w-full border border-gray-100 animate-in fade-in slide-in-from-top-4 duration-500">
        
        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-3xl font-extrabold text-gray-900 mb-2">Set New Password</h1>
            <p class="text-gray-500">Enter a strong, new password for your account.</p>
        </div>

        <!-- Form Start -->
        <form method="POST" action="/api/reset-password">
            <!-- Hidden field for token (must be dynamically provided by the system) -->
            <input type="hidden" name="token" value="{{ $token }}"> 
            
            <!-- Hidden field for email (must be dynamically provided by the system) -->
            <input type="hidden" name="email" value="{{ $email }}"> 

            <!-- New Password Field -->
            <div class="mb-6">
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                <div class="relative">
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        required 
                        placeholder="••••••••"
                        class="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm transition duration-150"
                        minlength="6"
                    >
                    <i data-lucide="lock" class="absolute right-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400"></i>
                </div>
                <p class="mt-2 text-xs text-gray-500">Must be at least 8 characters long.</p>
            </div>

            <!-- Confirm Password Field -->
            <div class="mb-8">
                <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                <div class="relative">
                    <input 
                        type="password" 
                        id="password_confirmation" 
                        name="password_confirmation" 
                        required 
                        placeholder="••••••••"
                        class="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm transition duration-150"
                    >
                    <i data-lucide="shield-check" class="absolute right-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400"></i>
                </div>
            </div>

            <!-- Submit Button -->
            <button 
                type="submit" 
                class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-md text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-200 transform hover:-translate-y-0.5"
            >
                <i data-lucide="refresh-cw" class="w-5 h-5 mr-2"></i>
                Reset Password
            </button>
        </form>
        <!-- Form End -->

        <!-- Back to Login Link -->
        <div class="mt-6 text-center">
            <a href="/login" class="text-sm font-medium text-indigo-600 hover:text-indigo-500 transition duration-150">
                <span class="mr-1">&larr;</span> Back to Login
            </a>
        </div>
    </div>
    
    <!-- Branding Footer -->
    <div class="absolute bottom-4 text-center">
        <p class="text-sm text-gray-400">&copy; {{ date('Y') }} ProjectFlow System</p>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>