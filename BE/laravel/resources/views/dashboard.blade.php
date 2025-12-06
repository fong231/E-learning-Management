<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - OC System</title>
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
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
        }
        .dropdown-menu {
            transition: all 0.2s ease-in-out;
            transform-origin: top right;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col">

    <header class="bg-card-bg shadow-md px-6 py-4 flex items-center justify-between sticky top-0 z-30">
        <div class="flex items-center">
            <h1 class="text-2xl font-bold text-primary-blue flex items-center">
                <i data-lucide="layout-dashboard" class="w-8 h-8 mr-2"></i>
                OC System
            </h1>
        </div>

        <div class="flex items-center space-x-6">
            <div class="relative" x-data="{ open: false }">
            {{-- Nút chuông --}}
            <button @click="open = !open" onclick="toggleNotifications()" class="text-text-muted hover:text-primary-blue p-2 rounded-full bg-light-bg transition duration-150 relative">
                <i data-lucide="bell" class="w-6 h-6"></i>
                
                
            </button>

            
        </div>

        {{-- Script để đóng mở dropdown --}}
        <script>
            function toggleNotifications() {
                const dropdown = document.getElementById('notification-dropdown');
                dropdown.classList.toggle('hidden');
            }

            // Close when click
            document.addEventListener('click', function(e) {
                const dropdown = document.getElementById('notification-dropdown');
                const button = e.target.closest('button'); // Find bell button

                if (!button && !dropdown.contains(e.target) && !dropdown.classList.contains('hidden')) {
                    dropdown.classList.add('hidden');
                }
            });
        </script>

            <div class="relative" id="profile-container">
                <div class="flex items-center space-x-2 cursor-pointer" id="profile-btn">
                    <img class="h-9 w-9 rounded-full object-cover border border-gray-200" 
                        src="{{ Auth::user()->avatar ? asset(Auth::user()->avatar) : 'https://ui-avatars.com/api/?name=' . urlencode(Auth::user()->full_name) . '&background=random&color=fff' }}" 
                        alt="{{ Auth::user()->full_name }}">
                        
                    <span class="text-sm font-medium text-text-dark hidden sm:block">
                        {{ Auth::user()->full_name }} </span>
                    
                    <i data-lucide="chevron-down" class="w-4 h-4 text-text-muted"></i>
                </div>

                <div id="profile-dropdown" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl border border-gray-100 py-2 z-50">
                    <a href="{{ route('profile.show') }}" class="block px-4 py-2 text-sm text-text-dark hover:bg-light-bg hover:text-primary-blue flex items-center">
                        <i data-lucide="user" class="w-4 h-4 mr-2"></i> Profile
                    </a>
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

    <main class="flex-1 overflow-x-hidden overflow-y-auto bg-light-bg p-6 lg:p-10">
        <div class="max-w-7xl mx-auto">
            @if (session('success'))
                <div id="success-alert" class="mb-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative flex items-center" role="alert">
                    <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                    <div>
                        <strong class="font-bold">Success!</strong>
                        <span class="block sm:inline">{{ session('success') }}</span>
                    </div>
                    <button onclick="document.getElementById('success-alert').remove()" class="absolute top-0 bottom-0 right-0 px-4 py-3">
                        <i data-lucide="x" class="w-4 h-4 text-green-500"></i>
                    </button>
                </div>
            @endif
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-text-dark">Welcome back</h1>
                <p class="text-text-muted mt-1">Here is what's happening with your projects today.</p>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">

                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col justify-between hover:shadow-md transition">
                    <div class="flex justify-between items-start mb-4">
                        <div class="p-3 rounded-full bg-red-50 text-red-500">
                            <i data-lucide="alert-circle" class="w-6 h-6"></i>
                        </div>
                        </div>
                    <div>
                        <p class="text-sm font-medium text-gray-500 mb-1">Pending Tasks</p>
                        <h3 class="text-3xl font-bold text-gray-800">{{ $pendingCount }}</h3>
                    </div>
                </div>

                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col justify-between hover:shadow-md transition">
                    <div class="flex justify-between items-start mb-4">
                        <div class="p-3 rounded-full bg-yellow-50 text-yellow-600">
                            <i data-lucide="clock" class="w-6 h-6"></i>
                        </div>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-500 mb-1">In Progress</p>
                        <h3 class="text-3xl font-bold text-gray-800">{{ $inProgressCount }}</h3>
                    </div>
                </div>

                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col justify-between hover:shadow-md transition">
                    <div class="flex justify-between items-start mb-4">
                        <div class="p-3 rounded-full bg-indigo-50 text-indigo-600">
                            <i data-lucide="folder" class="w-6 h-6"></i>
                        </div>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-500 mb-1">Total Projects</p>
                        <h3 class="text-3xl font-bold text-gray-800">{{ $totalProjects }}</h3>
                    </div>
                </div>

                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col justify-between hover:shadow-md transition">
                    <div class="flex justify-between items-start mb-4">
                        <div class="p-3 rounded-full bg-green-50 text-green-600">
                            <i data-lucide="check-circle-2" class="w-6 h-6"></i>
                        </div>
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-500 mb-1">Done Tasks</p>
                        <h3 class="text-3xl font-bold text-gray-800">{{ $doneCount }}</h3>
                    </div>
                </div>
            </div>
            
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                <div class="lg:col-span-2 space-y-6">
                    <div class="flex justify-between items-center">
                        <h2 class="text-xl font-bold text-text-dark">My Projects</h2>
                        <button onclick="openCreateProjectModal()" class="bg-primary-blue text-white px-4 py-2 rounded-lg hover:bg-indigo-700 text-sm font-medium shadow-sm transition flex items-center">
                            <i data-lucide="plus" class="w-4 h-4 mr-2"></i> Create New Project
                        </button>
                    </div>

                    <div id="projects-container" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 w-full">
                        <div class="col-span-full text-center py-12">
                            <i data-lucide="loader-2" class="w-10 h-10 animate-spin mx-auto mb-3 text-primary-blue"></i>
                            <p class="text-gray-500">Loading projects...</p>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-1">
                    <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                        <div class="flex justify-between items-center mb-6">
                            <h3 class="font-bold text-lg text-gray-800 flex items-center">
                                <i data-lucide="calendar-clock" class="w-5 h-5 mr-2 text-indigo-600"></i>
                                Upcoming Deadlines
                            </h3>
                            <a href="#" class="text-sm text-indigo-600 font-medium hover:underline">View All</a>
                        </div>

                        <div class="space-y-4">
                            @if(count($upcomingTasks) > 0)
                                @foreach($upcomingTasks as $task)
                                <a href="{{ url('/projects/' . $task['project_id']) }}" class="block group">
                                    <div class="p-4 rounded-lg border border-gray-100 hover:border-indigo-100 hover:shadow-sm transition bg-white group-hover:bg-indigo-50/30">
                                        <div class="flex justify-between items-start mb-2">
                                            <span class="text-[10px] font-bold px-2 py-1 rounded {{ $task['color_class'] }} uppercase tracking-wide">
                                                {{ $task['label'] }}
                                            </span>
                                            
                                            <i data-lucide="arrow-right" class="w-4 h-4 text-gray-300 group-hover:text-indigo-400 transition"></i>
                                        </div>
                                        
                                        <h4 class="font-bold text-gray-800 mb-1 truncate group-hover:text-indigo-700 transition">
                                            {{ $task['title'] }}
                                        </h4>
                                        
                                        <p class="text-xs text-gray-500 font-medium">
                                            {{ $task['project_name'] }}
                                        </p>
                                    </div>
                                </a>
                                @endforeach
                            @else
                                <div class="text-center py-8">
                                    <div class="bg-gray-50 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-3">
                                        <i data-lucide="coffee" class="w-6 h-6 text-gray-400"></i>
                                    </div>
                                    <p class="text-sm text-gray-500">No upcoming deadlines.</p>
                                    <p class="text-xs text-gray-400">Enjoy your free time!</p>
                                </div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <div id="createProjectModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 transition-opacity opacity-0">
        <div class="bg-white rounded-2xl p-8 max-w-lg w-full shadow-2xl transform scale-95 transition-transform duration-200" id="modalContent">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-2xl font-bold text-text-dark">Create New Project</h2>
                <button onclick="closeCreateProjectModal()" class="text-gray-400 hover:text-gray-600">
                    <i data-lucide="x" class="w-6 h-6"></i>
                </button>
            </div>
            
            <form action="{{ route('projects.store') }}" method="POST">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-text-dark mb-1">Project Name <span class="text-red-500">*</span></label>
                        <input type="text" name="name" required placeholder="e.g., Website Redesign" 
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-blue/50 focus:border-primary-blue transition">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-semibold text-text-dark mb-1">Description</label>
                        <textarea name="description" rows="3" placeholder="Briefly describe the project goals..." 
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-blue/50 focus:border-primary-blue transition"></textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold text-text-dark mb-1">Add Members (Optional)</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="users" class="w-5 h-5 text-gray-400"></i>
                            </div>
                            <input type="text" name="member_ids" placeholder="Enter Member IDs (e.g. 1, 5, 8)" 
                                class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-blue/50 focus:border-primary-blue transition">
                        </div>
                        <p class="text-xs text-gray-500 mt-1">Separate IDs with commas.</p>
                    </div>
                </div>

                <div class="mt-8 flex justify-end space-x-3">
                    <button type="button" onclick="closeCreateProjectModal()" class="px-5 py-2.5 text-gray-700 font-medium bg-gray-100 rounded-lg hover:bg-gray-200 transition">
                        Cancel
                    </button>
                    <button type="submit" class="px-5 py-2.5 bg-primary-blue text-white font-medium rounded-lg hover:bg-indigo-700 shadow-lg shadow-indigo-500/30 transition">
                        Create Project
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Initialize Icons
        lucide.createIcons();

        // --- Toggle Profile Dropdown ---
        const profileBtn = document.getElementById('profile-btn');
        const profileDropdown = document.getElementById('profile-dropdown');
        const profileContainer = document.getElementById('profile-container');

        profileBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            profileDropdown.classList.toggle('hidden');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', (e) => {
            if (!profileContainer.contains(e.target)) {
                profileDropdown.classList.add('hidden');
            }
        });

        // --- Modal Logic with Animation ---
        const modal = document.getElementById('createProjectModal');
        const modalContent = document.getElementById('modalContent');

        function openCreateProjectModal() {
            modal.classList.remove('hidden');
            // Small timeout to allow display:block to apply before opacity transition
            setTimeout(() => {
                modal.classList.remove('opacity-0');
                modalContent.classList.remove('scale-95');
                modalContent.classList.add('scale-100');
            }, 10);
        }

        function closeCreateProjectModal() {
            modal.classList.add('opacity-0');
            modalContent.classList.remove('scale-100');
            modalContent.classList.add('scale-95');
            setTimeout(() => {
                modal.classList.add('hidden');
            }, 200); // Wait for transition to finish
        }

        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                closeCreateProjectModal();
            }
        });

        // --- Hàm lấy Token  ---
        function getAuthHeaders() {
            return {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            };
        }

        // --- Hàm tải danh sách dự án ---
        async function loadProjects() {
            const container = document.getElementById('projects-container');
            
            container.innerHTML = `
                <div class="col-span-3 text-center py-10 text-gray-500">
                    <i data-lucide="loader-2" class="w-8 h-8 animate-spin mx-auto mb-2"></i>
                    Loading projects...
                </div>`;
            lucide.createIcons();

            try {
                // GỌI API
                const response = await fetch('/api/projects', {
                    method: 'GET',
                    headers: getAuthHeaders()
                });

                if (!response.ok) throw new Error('Failed to fetch projects');

                const result = await response.json(); 
                
                // Trích xuất mảng dự án từ thuộc tính 'data'
                const projects = result.data || result; 

                // Gọi hàm render
                renderProjects(projects);

            } catch (error) {
                console.error('Error:', error);
                container.innerHTML = `
                    <div class="col-span-3 text-center py-12 text-red-500">
                        <p>Failed to load projects. Please try again later.</p>
                    </div>`;
            }
        }

        // --- Hàm Render HTML ---
        function renderProjects(projects) {
            const container = document.getElementById('projects-container');
            
            // Cập nhật số lượng
            const countElement = document.getElementById('total-projects-count');
            if (countElement) countElement.innerText = projects.length;

            if (!projects || projects.length === 0) {
                container.innerHTML = `
                    <div class="col-span-full flex flex-col items-center justify-center py-12 bg-white rounded-xl border border-dashed border-gray-300">
                        <div class="p-3 bg-gray-50 rounded-full mb-3">
                            <i data-lucide="folder-plus" class="w-8 h-8 text-gray-400"></i>
                        </div>
                        <h3 class="text-sm font-semibold text-gray-900">No projects found</h3>
                        <p class="mt-1 text-sm text-gray-500">Get started by creating a new project.</p>
                    </div>`;
                lucide.createIcons();
                return;
            }

            const html = projects.map(project => {
                // Logic Avatar 
                const members = project.members || [];
                const displayMembers = members.slice(0, 3);
                const remainingCount = members.length - 3;

                const avatarsHtml = displayMembers.map(m => `
                    <img class="inline-block h-7 w-7 rounded-full ring-2 ring-white object-cover bg-gray-100" 
                        src="${m.avatar || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(m.full_name)}" 
                        alt="${m.full_name}" title="${m.full_name}">
                `).join('');

                let plusHtml = remainingCount > 0 ? `
                    <div class="h-7 w-7 rounded-full ring-2 ring-white bg-gray-100 flex items-center justify-center text-[10px] text-gray-500 font-medium">
                        +${remainingCount}
                    </div>` : '';

                // --- HTML CARD  ---
                return `
                    <div class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 cursor-pointer border border-gray-200 hover:border-primary-blue relative overflow-hidden flex flex-col h-full" 
                        onclick="window.location.href='/projects/${project.project_id}'">
                        
                        <div class="absolute top-0 left-0 w-1.5 h-full bg-primary-blue opacity-0 group-hover:opacity-100 transition-opacity duration-200"></div>
                        
                        <div class="p-5 flex-1 flex flex-col">
                            <div class="flex justify-between items-start mb-2 gap-2">
                                <h3 class="text-base font-bold text-gray-800 group-hover:text-primary-blue transition-colors line-clamp-1 break-all" 
                                    title="${project.name}">
                                    ${project.name}
                                </h3>
                                <span class="flex-shrink-0 bg-green-50 text-green-700 text-[10px] font-bold px-2 py-1 rounded-full uppercase tracking-wide border border-green-100">
                                    Active
                                </span>
                            </div>
                            
                            <p class="text-gray-500 text-sm mb-4 line-clamp-2 flex-1">
                                ${project.description || 'No description provided.'}
                            </p>
                            
                            <div class="flex justify-between items-center pt-3 border-t border-gray-100 mt-auto">
                                <div class="flex -space-x-1.5 overflow-hidden items-center pl-1">
                                    ${avatarsHtml}
                                    ${plusHtml}
                                </div>
                                
                                <div class="flex items-center text-gray-400 text-xs font-medium">
                                    <i data-lucide="list-checks" class="w-3.5 h-3.5 mr-1.5 text-primary-blue"></i> 
                                    ${project.tasks_count || 0} tasks
                                </div>
                            </div>
                        </div>
                    </div>
                `;
            }).join('');

            container.innerHTML = html;
            lucide.createIcons();
        }

        // Chạy khi trang load
        document.addEventListener('DOMContentLoaded', () => {
            loadProjects();
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