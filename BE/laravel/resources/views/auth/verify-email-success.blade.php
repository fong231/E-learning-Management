<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verification Successful - ProjectFlow</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .success-animation { animation: scaleUp 0.5s ease-out; }
        @keyframes scaleUp {
            0% { transform: scale(0.8); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body class="bg-gray-50 h-screen flex flex-col justify-center items-center px-4">

    <!-- Main Card -->
    <div class="bg-white p-8 rounded-2xl shadow-xl max-w-md w-full text-center success-animation border border-gray-100">
        
        <!-- Icon Circle -->
        <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100 mb-6">
            <i data-lucide="check-circle" class="h-10 w-10 text-green-600"></i>
        </div>

        <!-- Content -->
        <h1 class="text-2xl font-bold text-gray-900 mb-3">Email Verified Successfully!</h1>
        
        <p class="text-gray-600 mb-8 leading-relaxed">
            Thank you for verifying your email address. Your <strong>ProjectFlow</strong> account is now fully active and ready for use.
        </p>

        <!-- Action Button -->
        <a href="{{ route('dashboard') }}" class="block w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-4 rounded-lg transition duration-200 shadow-md hover:shadow-lg transform hover:-translate-y-0.5">
            Go to Dashboard
        </a>

        <!-- Footer Help -->
        <div class="mt-6 pt-6 border-t border-gray-100">
            <p class="text-xs text-gray-400">
                Need more assistance? <a href="#" class="text-indigo-600 hover:underline">Contact Support</a>
            </p>
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