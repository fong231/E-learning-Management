<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - OC System</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'primary-blue': '#4F46E5',
                        'light-bg': '#F9FAFB',
                        'card-bg': '#FFFFFF',
                        'text-dark': '#1F2937',
                        'text-muted': '#6B7280',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                }
            }
        }
    </script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #F9FAFB; }
        .form-input {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid #E5E7EB;
            border-radius: 0.5rem;
            outline: none;
            transition: all 0.2s;
        }
        .form-input:focus {
            border-color: #4F46E5;
            box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
        }
    </style>
</head>
<body class="min-h-screen flex flex-col">

    <header class="bg-card-bg shadow-md px-6 py-4 flex items-center justify-between sticky top-0 z-30">
        <a href="/dashboard" class="flex items-center hover:opacity-80 transition">
            <h1 class="text-2xl font-bold text-primary-blue flex items-center">
                <i data-lucide="layout-dashboard" class="w-8 h-8 mr-2"></i>
                OC System
            </h1>
        </a>
        
        <div class="flex items-center space-x-4">
            <a href="{{ route('dashboard') }}" class="text-sm font-medium text-text-muted hover:text-primary-blue flex items-center transition">
                <i data-lucide="arrow-left" class="w-4 h-4 mr-1"></i> Back to Dashboard
            </a>

            <div class="relative pl-4 border-l border-gray-200" id="profile-menu-container">
                
                <button onclick="toggleProfileMenu()" class="flex items-center space-x-2 focus:outline-none group">
                    <img class="h-9 w-9 rounded-full object-cover border border-gray-200 group-hover:border-primary-blue transition" 
                        src="{{ $user->avatar ? asset($user->avatar) : 'https://ui-avatars.com/api/?name=' . urlencode($user->full_name) . '&background=random&color=fff' }}" 
                        alt="{{ $user->full_name }}">
                    
                    <span class="text-sm font-medium text-text-dark hidden sm:block group-hover:text-primary-blue transition">
                        {{ $user->full_name }}
                    </span>
                    <i data-lucide="chevron-down" class="w-4 h-4 text-gray-400 group-hover:text-primary-blue"></i>
                </button>

                <div id="profile-dropdown-menu" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl border border-gray-100 py-2 z-50 transform origin-top-right transition-all">
                    
                    <div class="border-t border-gray-100 my-1"></div>

                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 flex items-center">
                            <i data-lucide="log-out" class="w-4 h-4 mr-2"></i> Logout
                        </button>
                    </form>
                </div>

            </div>
        </div>
    </header>
        
    <main class="flex-1 overflow-y-auto bg-light-bg p-6 lg:p-10">
        @if (session('success'))
            <div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
                <strong class="font-bold">Success!</strong>
                <span class="block sm:inline">{{ session('success') }}</span>
            </div>
        @endif

        @if ($errors->any())
            <div class="mb-6 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
                <strong class="font-bold">Whoops!</strong>
                <ul class="mt-1 list-disc list-inside text-sm">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif
        <div class="max-w-5xl mx-auto">
            
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-text-dark">Account Settings</h1>
                <p class="text-text-muted mt-1">Manage your profile information and security settings.</p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                <div class="lg:col-span-1 space-y-6">
                    
                    <div class="bg-card-bg rounded-xl shadow-sm border border-gray-100 p-6 text-center relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-full h-24 bg-gradient-to-r from-indigo-500 to-purple-600 opacity-10"></div>
                        
                        <div class="relative inline-block mt-4 mb-4 group">
                            <img class="h-28 w-28 rounded-full object-cover border-4 border-white shadow-lg mx-auto" 
                                 src="{{ $user->avatar ?? 'https://placehold.co/200x200/4F46E5/FFFFFF?text=VT' }}" 
                                 id="avatar-preview">
                            
                            <label for="avatar-upload" class="absolute bottom-0 right-0 bg-white p-2 rounded-full shadow-md cursor-pointer border border-gray-100 hover:text-primary-blue transition transform hover:scale-110">
                                <i data-lucide="camera" class="w-5 h-5"></i>
                            </label>
                            <input type="file" id="avatar-upload" class="hidden" accept="image/*" form="profile-form" name="avatar" onchange="previewImage(event)">
                        </div>

                        <h2 class="text-xl font-bold text-text-dark">{{ $user->full_name }}</h2>
                        <p class="text-text-muted text-sm mb-4">@ {{ $user->nickname ?? 'vtung_dev' }}</p>

                        <div class="flex justify-center space-x-2 mb-4">
                            <span class="px-3 py-1 bg-indigo-50 text-indigo-700 text-xs font-bold rounded-full uppercase tracking-wide">Developer</span>
                        </div>
                    </div>

                    <div class="bg-card-bg rounded-xl shadow-sm border border-gray-100 p-6">
                        <h3 class="text-sm font-bold text-text-dark uppercase tracking-wider mb-4">Work Performance</h3>
                        <div class="space-y-4">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center text-text-muted">
                                    <i data-lucide="folder" class="w-4 h-4 mr-2"></i> Projects Joined
                                </div>
                                <span class="font-bold text-text-dark">{{ $projectCount ?? 5 }}</span>
                            </div>
                            <div class="border-t border-gray-50"></div>
                            <div class="flex justify-between items-center">
                                <div class="flex items-center text-text-muted">
                                    <i data-lucide="check-circle" class="w-4 h-4 mr-2"></i> Tasks Completed
                                </div>
                                <span class="font-bold text-green-600">{{ $completedTasksCount ?? 42 }}</span>
                            </div>
                            <div class="border-t border-gray-50"></div>
                            <div class="flex justify-between items-center">
                                <div class="flex items-center text-text-muted">
                                    <i data-lucide="clock" class="w-4 h-4 mr-2"></i> Pending Tasks
                                </div>
                                <span class="font-bold text-red-500">{{ $pendingTasksCount ?? 3 }}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-2 space-y-8">
                    
                    <form id="profile-form" action="/api/profile/update" method="POST" enctype="multipart/form-data" class="bg-card-bg rounded-xl shadow-sm border border-gray-100 p-6 lg:p-8">
                        @csrf
                        @method('PATCH')
                        <div class="flex justify-between items-center mb-6">
                            <h3 class="text-lg font-bold text-text-dark flex items-center">
                                <i data-lucide="user" class="w-5 h-5 mr-2 text-primary-blue"></i>
                                Personal Information
                            </h3>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="col-span-2 md:col-span-1">
                                <label class="block text-sm font-semibold text-text-dark mb-2">Full Name</label>
                                <input type="text" name="fullname" value="{{ old('fullname', $user->full_name) }}" class="form-input">
                            </div>

                            <div class="col-span-2 md:col-span-1">
                                <label class="block text-sm font-semibold text-text-dark mb-2">Nickname</label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">@</span>
                                    <input type="text" name="nickname" value="{{ $user->nickname ?? 'vtung_dev' }}" class="form-input pl-8">
                                </div>
                            </div>

                            <div class="col-span-2">
                                <label class="block text-sm font-semibold text-text-dark mb-2">Email Address</label>
                                <div class="relative">
                                    <i data-lucide="mail" class="absolute top-3 left-3 w-5 h-5 text-gray-400"></i>
                                    <input type="email" value="{{ $user->email ?? 'tung.nguyen@example.com' }}" readonly class="form-input pl-10 bg-gray-50 text-gray-500 cursor-not-allowed">
                                </div>
                                <p class="text-xs text-text-muted mt-1">To change your email, please contact Administrator.</p>
                            </div>
                        </div>

                        <div class="mt-6 flex justify-end">
                            <button type="submit" class="bg-primary-blue text-white px-6 py-2 rounded-lg font-medium hover:bg-indigo-700 transition shadow-md shadow-indigo-500/30">
                                Save Changes
                            </button>
                        </div>
                    </form>

                    <form action="/api/profile/password" method="POST" class="bg-card-bg rounded-xl shadow-sm border border-gray-100 p-6 lg:p-8">
                        @csrf
                        @method('PUT')
                        <div class="flex justify-between items-center mb-6">
                            <h3 class="text-lg font-bold text-text-dark flex items-center">
                                <i data-lucide="lock" class="w-5 h-5 mr-2 text-primary-blue"></i>
                                Change Password
                            </h3>
                        </div>

                        <div class="space-y-4">
                            <div>
                                <label class="block text-sm font-semibold text-text-dark mb-2">Current Password</label>
                                <input type="password" name="current_password" class="form-input" placeholder="••••••••">
                            </div>
                            
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label class="block text-sm font-semibold text-text-dark mb-2">New Password</label>
                                    <input type="password" name="password" class="form-input" placeholder="••••••••">
                                </div>
                                <div>
                                    <label class="block text-sm font-semibold text-text-dark mb-2">Confirm New Password</label>
                                    <input type="password" name="password_confirmation" class="form-input" placeholder="••••••••">
                                </div>
                            </div>
                        </div>

                        <div class="mt-6 flex justify-end">
                            <button type="submit" class="bg-white text-text-dark border border-gray-300 px-6 py-2 rounded-lg font-medium hover:bg-gray-50 transition">
                                Update Password
                            </button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </main>

    <script>
        lucide.createIcons();
        document.addEventListener('DOMContentLoaded', function() {
            const alertBox = document.querySelector('[role="alert"]');
            if (alertBox) {
                setTimeout(function() {
                    alertBox.style.transition = 'opacity 0.5s ease';
                    alertBox.style.opacity = '0';
                    
                    setTimeout(() => alertBox.remove(), 500); 
                }, 3000);
            }
        });
        function previewImage(event) {
            const reader = new FileReader();
            reader.onload = function(){
                const output = document.getElementById('avatar-preview');
                output.src = reader.result;
            };
            if(event.target.files[0]) {
                reader.readAsDataURL(event.target.files[0]);
            }
        }
        
        function toggleProfileMenu() {
            const menu = document.getElementById('profile-dropdown-menu');
            menu.classList.toggle('hidden');
        }

        // Đóng menu khi click ra ngoài
        document.addEventListener('click', function(e) {
            const container = document.getElementById('profile-menu-container');
            const menu = document.getElementById('profile-dropdown-menu');
            
            // Nếu click không nằm trong container thì đóng menu
            if (container && !container.contains(e.target)) {
                if (!menu.classList.contains('hidden')) {
                    menu.classList.add('hidden');
                }
            }
        });

        document.addEventListener('DOMContentLoaded', () => {
            const alert = document.getElementById('success-alert');
            if (alert) {
                setTimeout(() => {
                    alert.style.transition = "opacity 0.5s ease";
                    alert.style.opacity = "0";
                    setTimeout(() => alert.remove(), 500);
                }, 3000);
            }
        });
    </script>
</body>
</html>