<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ProjectFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.30.1/moment.min.js"></script>
    <head>@vite(['resources/css/app.css', 'resources/js/app.js'])</head>
    <style>
        /* Fixed Height Layout */
        body { overflow: hidden; } /* Prevent body scroll, handle inside containers */
        
        /* Kanban Styles */
        .task-card {
            background: white;
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 12px;
            cursor: pointer;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid #e5e7eb;
            transition: all 0.2s;
            border-left: 4px solid transparent;
        }
        .task-card:hover {
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transform: translateY(-2px);
            border-color: #d1d5db;
        }
        .task-card.priority-high { border-left-color: #ef4444; }
        .task-card.priority-medium { border-left-color: #f59e0b; }
        .task-card.priority-low { border-left-color: #10b981; }
        
        .kanban-column {
            background: #f9fafb;
            border-radius: 12px;
            padding: 16px;
            height: 100%;
            overflow-y: auto;
            border: 1px solid #f3f4f6;
        }

        /* Sidebar Tab Styles */
        .sidebar-tab-btn {
            padding-bottom: 8px;
            color: #6b7280;
            font-size: 0.875rem;
            font-weight: 500;
            border-bottom: 2px solid transparent;
            transition: all 0.2s;
        }
        .sidebar-tab-btn:hover { color: #4f46e5; }
        .sidebar-tab-btn.active {
            color: #4f46e5;
            border-bottom-color: #4f46e5;
        }
        
        /* Scrollbar styling */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

        @keyframes fadeIn {
        from { opacity: 0; }
        to   { opacity: 1; }
        }

        @keyframes scaleIn {
            from { transform: scale(0.95); opacity: 0; }
            to   { transform: scale(1); opacity: 1; }
        }

        .animate-fadeIn {
            animation: fadeIn 0.18s ease-out;
        }
        .animate-scaleIn {
            animation: scaleIn 0.22s ease-out;
        }
    </style>
</head>

<body class="bg-white font-sans h-screen flex flex-col">
    @php
        $currentUser = Auth::user();
        $isOwner = $project->owner_id == $currentUser->customer_id;
        
        // SỬA LỖI TẠI ĐÂY: Không dùng $members nữa mà query trực tiếp từ quan hệ
        // Lấy bản ghi ProjectMember của user hiện tại (nếu có)
        $membership = $project->members()->where('member_id', $currentUser->customer_id)->first();
        $userRole = $membership ? $membership->role : null;
        
        // Quyền sửa: Là Owner HOẶC Manager
        $canEditStatus = $isOwner || $userRole === 'manager';
    @endphp
    <nav class="bg-white border-b border-gray-200 h-16 flex-shrink-0 z-50 sticky top-0 relative">
        <div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8 h-full">
            <div class="flex justify-between items-center h-full">
                
                <div class="flex items-center space-x-4">
                    <a href="{{ route('dashboard') }}" class="text-gray-500 hover:text-indigo-600 flex items-center transition text-sm font-medium">
                        <i data-lucide="arrow-left" class="w-4 h-4 mr-1"></i> Back
                    </a>
                    <div class="h-6 w-px bg-gray-200"></div>
                    <div>
                        <h1 class="text-lg font-bold text-gray-800 flex items-center">
                            {{ $project->name }}
                            <span class="ml-3 bg-indigo-50 text-indigo-700 text-xs px-2 py-0.5 rounded-full border border-indigo-100">Active</span>
                        </h1>
                    </div>
                </div>
                
                <div class="flex items-center space-x-4">
                    
                    <div class="relative">
                        <button onclick="toggleNotifications()" class="p-2 text-gray-400 hover:text-indigo-600 rounded-full hover:bg-gray-100 transition relative focus:outline-none">
                            <i data-lucide="bell" class="w-5 h-5"></i>
                            @if(isset($notifications) && $notifications->count() > 0)
                                <span class="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
                            @endif
                        </button>

                        <div id="proj-notification-dropdown" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-2xl border border-gray-100 z-50 overflow-hidden">
                            <div class="p-3 border-b border-gray-50 flex justify-between items-center bg-gray-50">
                                <h3 class="font-bold text-gray-800 text-xs uppercase">Notifications</h3>
                                @if(isset($notifications) && $notifications->count() > 0)
                                    <a href="{{ route('notifications.markAll') }}" class="text-xs text-indigo-600 hover:underline">Mark read</a>
                                @endif
                            </div>
                            <div class="max-h-64 overflow-y-auto">
                                @if(isset($notifications))
                                    @forelse($notifications as $notify)
                                        <a href="{{ route('notifications.read', $notify->id) }}" class="block p-3 border-b border-gray-50 hover:bg-gray-50 transition">
                                            <p class="text-sm font-medium text-gray-800">{{ $notify->data['title'] ?? 'Notification' }}</p>
                                            <p class="text-xs text-gray-500 truncate">{{ $notify->data['message'] ?? '' }}</p>
                                        </a>
                                    @empty
                                        <div class="p-4 text-center text-gray-400 text-sm">No new notifications</div>
                                    @endforelse
                                @endif
                            </div>
                        </div>
                    </div>

                    <div class="relative ml-4 pl-4 border-l border-gray-200">
                        {{-- 1. Nút bấm để mở menu --}}
                        <button onclick="toggleTopProfileMenu()" class="flex items-center space-x-2 focus:outline-none group">
                            <span class="text-gray-700 font-medium text-sm hidden sm:block group-hover:text-indigo-600 transition">
                                {{ Auth::user()->full_name }}
                            </span>
                            <img class="h-8 w-8 rounded-full border border-gray-200 object-cover group-hover:border-indigo-600 transition" 
                                src="{{ Auth::user()->avatar ? asset(Auth::user()->avatar) : 'https://ui-avatars.com/api/?name=' . urlencode(Auth::user()->full_name) . '&background=random&color=fff' }}" 
                                alt="Avatar"/>
                            <i data-lucide="chevron-down" class="w-4 h-4 text-gray-400 group-hover:text-indigo-600"></i>
                        </button>

                        {{-- 2. Menu thả xuống (ID: top-profile-menu) --}}
                        <div id="top-profile-menu" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl border border-gray-100 py-2 z-50 origin-top-right">
                            
                            <a href="{{ route('dashboard') }}" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-indigo-600 flex items-center transition">
                                <i data-lucide="layout-dashboard" class="w-4 h-4 mr-2"></i> Dashboard
                            </a>

                            <a href="{{ route('profile.show') }}" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-indigo-600 flex items-center transition">
                                <i data-lucide="user" class="w-4 h-4 mr-2"></i> My Profile
                            </a>
                            
                            <div class="border-t border-gray-100 my-1"></div>

                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <button type="submit" class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 flex items-center transition">
                                    <i data-lucide="log-out" class="w-4 h-4 mr-2"></i> Logout
                                </button>
                            </form>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </nav>

    <div class="flex-1 flex overflow-hidden">
        
        <main class="flex-1 overflow-x-auto overflow-y-hidden bg-white p-6 border-r border-gray-200">
            <div class="h-full flex flex-col">
                <div class="flex justify-between items-center mb-4 flex-shrink-0">
                    <h2 class="text-lg font-bold text-gray-800">Task Board</h2>
                    <button id="btn-open-create-task" onclick="openCreateTaskModal()" class="bg-indigo-600 text-white px-3 py-2 rounded-md hover:bg-indigo-700 transition flex items-center text-sm font-medium shadow-sm">
                        <i data-lucide="plus" class="w-4 h-4 mr-2"></i> New Task
                    </button>
                </div>

                <div class="flex-1 grid grid-cols-1 md:grid-cols-3 gap-6 min-w-[800px] h-full pb-2">
    
                    <div class="kanban-column flex flex-col h-full bg-gray-50 rounded-lg border border-gray-200">
                        <div class="flex items-center justify-between p-3 border-b border-gray-200 bg-gray-100 rounded-t-lg">
                            <h3 class="font-bold text-sm text-gray-700 flex items-center">
                                <div class="w-2 h-2 rounded-full bg-gray-500 mr-2"></div> TO DO
                            </h3>
                            <span id="todo-count" class="bg-white text-gray-600 text-xs font-bold px-2 py-0.5 rounded-full border border-gray-300">0</span>
                        </div>

                        <!-- TODO COLUMN -->
                        <div id="todo-column" class="p-3 space-y-3 overflow-y-auto flex-1 min-h-[100px]">
                            </div>
                    </div>

                    <div class="kanban-column flex flex-col h-full bg-blue-50/50 rounded-lg border border-blue-100">
                        <div class="flex items-center justify-between p-3 border-b border-blue-200 bg-blue-100/50 rounded-t-lg">
                            <h3 class="font-bold text-sm text-blue-700 flex items-center">
                                <div class="w-2 h-2 rounded-full bg-blue-500 mr-2"></div> IN PROGRESS
                            </h3>
                            <span id="in_progress-count" class="bg-white text-blue-600 text-xs font-bold px-2 py-0.5 rounded-full border border-blue-200">0</span>
                        </div>

                        <!-- IN PROGRESS COLUMN -->
                        <div id="in_progress-column" class="p-3 space-y-3 overflow-y-auto flex-1 min-h-[100px]"></div>
                    </div>

                    <div class="kanban-column flex flex-col h-full bg-green-50/50 rounded-lg border border-green-100">
                        <div class="flex items-center justify-between p-3 border-b border-green-200 bg-green-100/50 rounded-t-lg">
                            <h3 class="font-bold text-sm text-green-700 flex items-center">
                                <div class="w-2 h-2 rounded-full bg-green-500 mr-2"></div> DONE
                            </h3>
                            <span id="done-count" class="bg-white text-green-600 text-xs font-bold px-2 py-0.5 rounded-full border border-green-200">0</span>
                        </div>

                        <!-- DONE COLUMN -->
                        <div id="done-column" class="p-3 space-y-3 overflow-y-auto flex-1 min-h-[100px]"></div>
                    </div>
                </div>
            </div>
        </main>

        <aside class="w-80 bg-white flex flex-col flex-shrink-0">
            
            <div class="px-4 pt-4 pb-0 border-b border-gray-200 flex justify-between items-center">
                <button onclick="switchSidebarTab('chat')" id="tab-btn-chat" class="sidebar-tab-btn active flex-1 text-center">
                    Chat
                </button>
                <button onclick="switchSidebarTab('files')" id="tab-btn-files" class="sidebar-tab-btn flex-1 text-center">
                    Files
                </button>
                <button onclick="switchSidebarTab('members')" id="tab-btn-members" class="sidebar-tab-btn flex-1 text-center">
                    Members
                </button>
            </div>

            <div class="flex-1 overflow-y-auto bg-gray-50 p-0 relative">

                <!-- CHAT -->
                <div id="sidebar-chat" class="sidebar-content hidden flex-1 flex flex-col justify-between absolute inset-0">
                    <div id="chat-list-view" class="flex-1 overflow-y-auto bg-white flex flex-col">
                        
                        <div id="project-chat-button" onclick="openProjectChat()" class="p-4 bg-white border-b border-gray-100 hover:bg-indigo-50 cursor-pointer transition group">
                            <div class="flex items-center space-x-3">
                                <div class="relative">
                                    <div class="w-10 h-10 bg-indigo-100 text-indigo-600 rounded-lg flex items-center justify-center">
                                        <i data-lucide="hash" class="w-5 h-5"></i>
                                    </div>
                                    <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-baseline">
                                        <p class="text-sm font-bold text-gray-900 truncate group-hover:text-indigo-700">General Project Chat</p>
                                        <span id="project-chat-latest-time" class="text-xs text-gray-400"></span>
                                    </div>
                                    <p class="text-xs text-gray-500 truncate">
                                        <span id="project-chat-latest-sender"></span>
                                        <span id="project-chat-latest-message"></span>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="px-4 py-2 bg-gray-50 border-b border-gray-200 flex-shrink-0">
                            <h4 class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Direct Messages</h4>
                        </div>

                        <div id="private-chats" class="flex-1 overflow-y-auto bg-white">
                            
                        </div>
                    </div>
                    
                    <div id="chat-main-view" class="hidden absolute inset-0 flex flex-col justify-between bg-white">
                        
                        <div class="flex items-center p-4 border-b border-gray-200 bg-gray-50 flex-shrink-0">
                            <button onclick="closeChat()" class="text-gray-500 hover:text-indigo-600 mr-3">
                                <i data-lucide="arrow-left" class="w-5 h-5"></i>
                            </button>
                            <img id="chat-header-avatar" class="w-9 h-9 mr-3 hidden rounded-full" src="" alt="Avatar">
                            <h4 id="chat-header-title" class="text-base font-bold text-gray-800">General Project Chat</h4>
                        </div>

                        <div id="pinned-section" class="hidden flex-col bg-yellow-50 border-b border-yellow-200 flex-shrink-0 transition-all duration-300 z-10">
    
                            <div onclick="window.pinMessage.togglePinnedList()" class="flex items-center justify-between px-4 py-2 cursor-pointer hover:bg-yellow-100 transition select-none">
                                <div class="flex items-center space-x-2 text-yellow-800">
                                    <i data-lucide="pin" class="w-4 h-4 fill-current"></i>
                                    <span class="text-xs font-bold">
                                        <span id="pinned-count">0</span> Pinned Messages
                                    </span>
                                </div>
                                <i id="pinned-chevron" data-lucide="chevron-down" class="w-4 h-4 text-yellow-600 transition-transform duration-200"></i>
                            </div>

                            <div id="pinned-list" class="hidden px-4 pb-3 space-y-2 max-h-48 overflow-y-auto border-t border-yellow-100 shadow-inner bg-yellow-50/50">
                                </div>
                        </div>

                        <div id="chat-messages-list" class="flex-1 overflow-y-auto p-4 text-sm space-y-4">
                            <div class="text-center text-gray-500 py-4" id="chat-loading-status">
                                <i data-lucide="loader" class="w-4 h-4 mr-2 animate-spin"></i> Loading messages...
                            </div>

                            <!-- Chat messages container -->
                            <div id="chat-messages-container"></div>

                            <div class="flex justify-end pr-2 hidden" id="chat-sending-status">
                                <div class="flex items-center space-x-2 text-xs text-blue-500 p-2 bg-blue-50 rounded-lg shadow-sm">
                                    <span>Sending...</span>
                                    <i data-lucide="loader" class="w-3 h-3 animate-spin"></i> 
                                </div>
                            </div>
                        </div>

                        <div class="border-t pt-3 px-4 pb-2 bg-white flex-shrink-0">
                            <input type="file" id="chat-file-input" class="hidden" multiple>

                            <div id="file-preview-container" class="mb-2 hidden">
                                <span class="text-xs text-gray-500">Attached: </span>
                            </div>
                            
                            <form id="chat-send-form" class="flex items-end space-x-2">
                                <button type="button" id="chat-attach-btn" class="p-2 h-10 w-10 text-gray-500 bg-gray-100 rounded-lg hover:bg-gray-200 transition flex items-center justify-center flex-shrink-0" title="Đính kèm file">
                                    <i data-lucide="paperclip" class="w-5 h-5"></i>
                                </button>

                                <textarea id="chat-input" 
                                        placeholder="Type a message..." 
                                        class="flex-1 p-2 border border-gray-300 rounded-lg resize-none focus:ring-blue-500 focus:border-blue-500 transition"
                                        rows="1"
                                        style="min-height: 40px; max-height: 120px;"></textarea>

                                <button type="submit" id="chat-send-btn" class="p-2 h-10 w-10 text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition flex items-center justify-center flex-shrink-0 disabled:opacity-50">
                                    <i data-lucide="send" class="w-4 h-4"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- FILE -->
                <div id="sidebar-files" class="sidebar-content absolute inset-0 hidden flex-col bg-white p-4 overflow-y-auto space-y-4">

                    <div id="imagePreviewModal" class="hidden fixed inset-0 bg-gray-900 bg-opacity-75 flex items-center justify-center z-50 p-4 backdrop-blur-sm transition-opacity duration-300">
    
                        <div class="relative max-w-4xl max-h-full w-full">
                            <button onclick="closeImagePreviewModal()" 
                                    class="absolute -top-10 right-0 text-white hover:text-gray-300 transition focus:outline-none">
                                <i data-lucide="x" class="w-8 h-8"></i>
                            </button>

                            <div id="imagePreviewContent" class="rounded-lg shadow-2xl max-h-full flex items-center justify-center">
                                <img id="imagePreviewImg" 
                                    src="" 
                                    alt="Preview image" 
                                    class="max-w-full max-h-[90vh] object-contain rounded-lg">
                            </div>
                        </div>
                    </div>
                </div>

                <div id="sidebar-members" class="sidebar-content absolute inset-0 hidden bg-white overflow-y-auto flex flex-col">
                    <div class="p-4">
                        <h3 class="flex text-xs font-bold text-gray-500 uppercase tracking-wider mb-3">
                            Project Team (<span id="member-count">0</span>)
                            <button onclick="showAddMemberModal()" class="ml-auto text-sm text-indigo-600 hover:underline">Add Member</button>
                        </h3>
                        <ul id="members-list" class="space-y-4">
                            <li class="text-center text-gray-400 text-sm py-4">Loading members...</li>
                        </ul>

                        <div id="addMemberModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
                            <div class="bg-white rounded-xl shadow-2xl p-6 max-w-lg w-full transform transition-all scale-100">
                                <div class="flex justify-between items-center mb-5">
                                    <h2 class="text-xl font-bold text-gray-800">Add Member</h2>
                                    <button onclick="closeAddMemberModal()" class="text-gray-400 hover:text-gray-600">
                                        <i data-lucide="x" class="w-6 h-6"></i>
                                    </button>
                                </div>
                                <div class="space-y-4">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Member ID</label>
                                        <input type="text" id="member-id-input" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none" placeholder="e.g., 123456">
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                                        <select id="member-role-select" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none">
                                            <option value="member" selected>Member</option>
                                            <option value="manager">Manager</option>
                                        </select>
                                    </div>
                                    <button id="add-member-btn" onclick="addMember()" class="w-full bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-50">Add Member</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </aside>
    </div>

    <div id="taskDetailModalContainer">
        @include('tasks.show') 
    </div>

    <!-- MODAL CREATE TASK (Đã nâng cấp UI) -->
    <div id="createTaskModal" 
        class="hidden fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4
            animate-fadeIn">
        
        <div class="relative w-full max-w-lg rounded-2xl bg-white shadow-2xl ring-1 ring-black/[0.06]
                    transform animate-scaleIn">

            <!-- Header -->
            <div class="flex items-center justify-between border-b border-slate-200 px-6 py-4">
                <h3 class="text-xl font-semibold text-slate-800 tracking-tight">Create New Task</h3>
                <button type="button" onclick="closeCreateTaskModal()" 
                    class="rounded-lg p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <!-- Body -->
            <div class="p-6">
                <form id="create-task-form" onsubmit="return false;">
                    @csrf
                    <input type="hidden" name="project_id" value="{{ $project->project_id }}">

                    <div class="space-y-6">

                        <!-- Title -->
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1.5">
                                Task Title <span class="text-red-500">*</span>
                            </label>
                            <input type="text" name="title" required
                                class="w-full rounded-xl border border-slate-300 bg-slate-50 px-4 py-3 text-slate-900 
                                    transition focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 focus:bg-white"
                                placeholder="e.g., Fix navigation bar bug">
                        </div>

                        <!-- Priority + Due Date -->
                        <div class="grid grid-cols-1 gap-6 md:grid-cols-2">

                            <!-- Priority -->
                            <div>
                                <label class="block text-sm font-medium text-slate-700 mb-1.5">Priority</label>
                                <div class="relative">
                                    <select name="priority"
                                        class="w-full appearance-none rounded-xl border border-slate-300 bg-slate-50 px-4 py-3
                                            text-slate-900 focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 
                                            focus:bg-white cursor-pointer transition">
                                        <option value="low">Low</option>
                                        <option value="medium" selected>Medium</option>
                                        <option value="high">High</option>
                                    </select>
                                    <i data-lucide="chevron-down"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 w-4 h-4 pointer-events-none"></i>
                                </div>
                            </div>

                            <!-- Due Date -->
                            <div>
                                <label class="block text-sm font-medium text-slate-700 mb-1.5">Due Date</label>
                                <input type="date" name="due_date"
                                    class="w-full rounded-xl border border-slate-300 bg-slate-50 px-4 py-3 text-slate-900 
                                        focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 focus:bg-white transition">
                            </div>
                        </div>

                        <!-- Assignee -->
                        <!-- Assign To (Multiple Select) -->
                        <div>
                            <label class="mb-1.5 block text-sm font-semibold text-gray-700">Assign To</label>
                            
                            <!-- Input ẩn để chứa danh sách ID (Gửi lên server) -->
                            <input type="hidden" name="assignee_ids" id="assignee_ids_input">

                            <div class="relative">
                                <select id="task-assignee-select" onchange="addAssignee(this)"
                                    class="appearance-none block w-full rounded-lg border border-gray-300 bg-gray-50 px-4 py-2.5 text-gray-900 focus:border-indigo-500 focus:bg-white focus:ring-2 focus:ring-indigo-500/20 outline-none transition cursor-pointer">
                                    <option value="">+ Add member...</option>
                                    <!-- JS sẽ điền danh sách thành viên vào đây -->
                                </select>
                                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-gray-500">
                                    <i data-lucide="user-plus" class="w-4 h-4"></i>
                                </div>
                            </div>

                            <!-- Khu vực hiển thị danh sách người đã chọn -->
                            <div id="selected-assignees-container" class="flex flex-wrap gap-2 mt-3">
                                <!-- Ví dụ tag mẫu (JS sẽ render tương tự thế này):
                                <div class="flex items-center bg-indigo-50 text-indigo-700 px-3 py-1 rounded-full text-sm font-medium border border-indigo-100">
                                    <img src="..." class="w-5 h-5 rounded-full mr-2">
                                    Nguyen Van A
                                    <button type="button" onclick="removeAssignee(1)" class="ml-2 text-indigo-400 hover:text-indigo-600">
                                        <i data-lucide="x" class="w-3 h-3"></i>
                                    </button>
                                </div> 
                                -->
                            </div>
                        </div>

                        <!-- Description -->
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1.5">Description</label>
                            <textarea name="description" rows="4"
                                class="w-full rounded-xl border border-slate-300 bg-slate-50 px-4 py-3 text-slate-900
                                    focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 focus:bg-white transition
                                    resize-none"
                                placeholder="Describe the task details..."></textarea>
                        </div>

                    </div>

                    <!-- Footer -->
                    <div class="mt-8 flex items-center justify-end space-x-3 border-t border-slate-200 pt-5">

                        <button type="button" onclick="closeCreateTaskModal()"
                            class="rounded-xl border border-slate-300 bg-white px-5 py-2.5 text-sm font-medium 
                                text-slate-700 hover:bg-slate-100 hover:text-slate-900 transition">
                            Cancel
                        </button>

                        <button type="submit"
                            class="flex items-center rounded-xl bg-indigo-600 px-6 py-2.5 text-sm font-medium 
                                text-white shadow-md shadow-indigo-500/20 hover:bg-indigo-700 transition">
                            <i data-lucide="plus" class="w-4 h-4 mr-2"></i>
                            Create Task
                        </button>

                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        lucide.createIcons();
        
        const projectId = {{ $project->project_id }};
        let currentUserId, otherUserId = null, isOwner = false;;
        let chatFileInput, chatAttachBtn, chatPreviewContainer, chatInput, chatSendForm;
        const canEdit = {{ isset($canEditStatus) && $canEditStatus ? 'true' : 'false' }};
        let selectedAssigneeIds = [];
        let selectedAssignees = [];
        let projectMembersData = [];

        // --- TOGGLE MENU / NOTIFICATION ---
        
        function toggleTopProfileMenu() {
            const menu = document.getElementById('top-profile-menu');
            if(menu) menu.classList.toggle('hidden');
            
            const notiDropdown = document.getElementById('proj-notification-dropdown');
            if (notiDropdown && !notiDropdown.classList.contains('hidden')) {
                notiDropdown.classList.add('hidden');
            }
        }

        function toggleNotifications() {
            const dropdown = document.getElementById('proj-notification-dropdown');
            if(dropdown) dropdown.classList.toggle('hidden');
            
            // Đóng profile nếu đang mở
            const profileMenu = document.getElementById('top-profile-menu') || document.getElementById('proj-profile-menu');
            if (profileMenu) profileMenu.classList.add('hidden');
        }

        // Logic đóng khi click ra ngoài
        window.addEventListener('click', function(e) {
            // Xử lý Top Profile Menu
            const topMenu = document.getElementById('top-profile-menu');
            const topBtn = document.querySelector('button[onclick="toggleTopProfileMenu()"]');
            if (topMenu && topBtn && !topBtn.contains(e.target) && !topMenu.contains(e.target)) {
                topMenu.classList.add('hidden');
            }

            // Xử lý Notification
            const notiMenu = document.getElementById('proj-notification-dropdown');
            const notiBtn = document.querySelector('button[onclick="toggleNotifications()"]');
            if (notiMenu && notiBtn && !notiBtn.contains(e.target) && !notiMenu.contains(e.target)) {
                notiMenu.classList.add('hidden');
            }
        });

        // --- MODAL & SIDEBAR ---

        function switchSidebarTab(tabName) {
            document.querySelectorAll('.sidebar-content').forEach(el => el.classList.add('hidden'));
            document.querySelectorAll('.sidebar-tab-btn').forEach(btn => {
                btn.classList.remove('active');
                btn.classList.add('text-gray-500');
            });
            const content = document.getElementById('sidebar-' + tabName);
            if(content) {
                content.classList.remove('hidden');
                content.classList.add('flex');
            }
            const btn = document.getElementById('tab-btn-' + tabName);
            if(btn) {
                btn.classList.add('active');
                btn.classList.remove('text-gray-500');
            }
        }

        function openCreateTaskModal() { 
            const m = document.getElementById('createTaskModal');
            if(m) {
                m.classList.remove('hidden'); 
                // Reset form
                document.getElementById('create-task-form').reset();
                const dateInput = form.querySelector('input[name="due_date"]');
                //Date
                if (dateInput) {
                    const today = new Date().toISOString().split('T')[0];
                    
                    dateInput.min = today;
                }
                // Reset assignee list
                selectedAssigneeIds = [];
                renderSelectedAssignees();
            }
        }
        
        function closeCreateTaskModal() { 
            const m = document.getElementById('createTaskModal');
            if(m) m.classList.add('hidden'); 
        }
        
        function closeTaskDetailModal() {
            const m = document.getElementById('taskDetailModal');
            if(m) m.classList.add('hidden');
        }

        async function openTaskDetailModal(taskId) {
            const modal = document.getElementById('taskDetailModal');
            if(!modal) return;
            modal.classList.remove('hidden');
            
            // Reset UI
            const titleEl = document.getElementById('modal-task-title');
            if(titleEl) titleEl.innerText = 'Loading...';
            const descEl = document.getElementById('modal-task-description');
            if(descEl) descEl.innerHTML = '<p>Loading details...</p>';
            renderTaskFiles([]); // Reset file list

            // Reset Assignee Container (Xóa danh sách cũ)
            const assigneeContainer = document.getElementById('modal-task-assignees-container');
            if (assigneeContainer) assigneeContainer.innerHTML = '';

            try {
                let response = await fetch(`/api/projects/${projectId}/tasks/${taskId}`, {
                    headers: { 'Accept': 'application/json' }
                });
                
                if (!response.ok) throw new Error('Failed to load task');
                
                const json = await response.json();
                const task = json.data || json;

                // Điền dữ liệu Task
                if(document.getElementById('modal-task-id-display')) {
                    document.getElementById('modal-task-id-display').innerText = `#TSK-${task.task_id}`;
                    document.getElementById('modal-task-id-display').dataset.taskId = task.task_id;
                }
                if(titleEl) titleEl.innerText = task.title;
                if(descEl) descEl.innerText = task.description || 'No description provided.';
                
                const dateEl = document.getElementById('modal-task-duedate');
                if(dateEl) dateEl.innerText = task.due_date || 'No date';
                
                const createdEl = document.getElementById('modal-task-created');
                if(createdEl) createdEl.innerText = new Date(task.created_at).toLocaleDateString();
                
                const statusSelect = document.getElementById('modal-task-status');
                if(statusSelect) {
                    const newSelect = statusSelect.cloneNode(true);
                    statusSelect.parentNode.replaceChild(newSelect, statusSelect);
                    
                    newSelect.value = task.status; 
                    
                    if(!canEdit) {
                        newSelect.disabled = true;
                        newSelect.classList.add('opacity-50', 'cursor-not-allowed');
                    } else {
                        newSelect.disabled = false;
                        newSelect.classList.remove('opacity-50', 'cursor-not-allowed');
                        
                        // Gắn sự kiện Change
                        newSelect.addEventListener('change', function() {
                            
                            // Gọi hàm chuyển cột
                            updateTaskStatus(task.task_id, this.value);
                        });
                    }
                }

                const deleteBtn = document.getElementById('btn-delete-task');
                if (deleteBtn) {
                    // Clone để xóa event cũ
                    const newDeleteBtn = deleteBtn.cloneNode(true);
                    deleteBtn.parentNode.replaceChild(newDeleteBtn, deleteBtn);

                    // Kiểm tra quyền (Chỉ Owner/Manager mới được xóa)
                    if (canEdit) {
                        newDeleteBtn.classList.remove('hidden');
                        newDeleteBtn.onclick = function() {
                            deleteTask(task.task_id);
                        };
                    } else {
                        newDeleteBtn.classList.add('hidden');
                    }
                }
                // Priority
                const prioritySpan = document.getElementById('modal-task-priority');
                if(prioritySpan) {
                    prioritySpan.innerText = task.priority;
                    prioritySpan.className = 'px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider';
                    if(task.priority === 'high') prioritySpan.classList.add('bg-red-100', 'text-red-600');
                    else if(task.priority === 'medium') prioritySpan.classList.add('bg-yellow-100', 'text-yellow-600');
                    else prioritySpan.classList.add('bg-green-100', 'text-green-600');
                }

                // --- SỬA PHẦN NÀY: ASSIGNEE (HIỂN THỊ NHIỀU NGƯỜI) ---
                if (assigneeContainer) {
                    // Kiểm tra xem có người nào không
                    if (task.assignees && task.assignees.length > 0) {
                        // Duyệt qua từng người và cộng dồn HTML
                        task.assignees.forEach(assignee => {
                            const avatarSrc = assignee.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(assignee.full_name)}&background=random&color=fff`;
                            
                            assigneeContainer.innerHTML += `
                                <div class="flex items-center mb-2 p-1 hover:bg-gray-50 rounded transition">
                                    <img src="${avatarSrc}" class="w-8 h-8 rounded-full mr-2 border border-gray-200 object-cover">
                                    <div>
                                        <p class="text-sm font-medium text-gray-800">${assignee.full_name}</p>
                                        <p class="text-xs text-gray-500">${assignee.email || ''}</p>
                                    </div>
                                </div>
                            `;
                        });
                    } else {
                        // Nếu không có ai
                        assigneeContainer.innerHTML = `
                            <div class="flex items-center text-gray-400 italic text-sm">
                                <i data-lucide="user-x" class="w-4 h-4 mr-2"></i> Unassigned
                            </div>
                        `;
                    }
                }
                // --- KẾT THÚC PHẦN SỬA ---

                // --- GỌI HÀM RENDER FILE ---
                response = await window.api.getTaskResources(projectId, taskId);

                let resources = response;
                if (resources.success) {
                    resources = resources.data;
                }
                renderTaskFiles(resources || []);
                
                // Tạo icon cho các phần vừa render
                if(window.lucide) lucide.createIcons();

            } catch (error) {
                console.error(error);
                if(titleEl) titleEl.innerText = 'Error loading task';
            }
        }

        // --- LOGIC API & RENDER ---

        async function loadProjectData() {
            try {
                let response = await window.api.getProject(projectId);
                if (!response.success) throw new Error('Failed to load data');
                let data = response.data;

                response = await window.api.getMe();
                if (!response.success) throw new Error('Failed to load data');
                currentUserId = response.data.customer_id;
                window.Echo.private(`private.${currentUserId}`).listen('PrivateMessageSent', (e) => {
                    renderNewMessages([e.message]);
                    
                });

                window.Echo.private(`project.${projectId}`).listen('GroupMessageSent', (e) => {
                    if (currentUserId === e.message.sender.customer_id) return;
                    renderNewMessages([e.message]);
                });

                data.owner.role = 'owner';

                [...data.members, data.owner].forEach(m => {
                    if (m.customer_id === currentUserId && m.role === 'owner') {
                        isOwner = true;
                    }
                });

                renderKanban(data.tasks || []);
                renderMembers([...data.members, data.owner] || []);
                renderChats([...data.members, data.owner] || []);

            } catch (error) {
                console.error(error);
            }
        }

        function renderKanban(tasks) {
            // 1. Reset cột
            ['todo', 'in_progress', 'done'].forEach(id => {
                const col = document.getElementById(id + '-column');
                const cnt = document.getElementById(id + '-count');
                if(col) col.innerHTML = '';
                if(cnt) cnt.innerText = '0';
            });

            if (!tasks || tasks.length === 0) return;

            tasks.forEach(task => {
                // 2. Logic chọn cột
                let target = 'todo';
                const s = String(task.status || '').toLowerCase();
                
                if (['done', 'completed', '3'].includes(s)) target = 'done';
                else if (['in_progress', 'in-progress', 'doing', '2'].includes(s)) target = 'in_progress';

                const col = document.getElementById(target + '-column');
                const cnt = document.getElementById(target + '-count');

                if (col) {
                    // Tăng số đếm
                    if(cnt) cnt.innerText = parseInt(cnt.innerText) + 1;

                    // --- 3. LOGIC MÀU SẮC (Dùng Background Color) ---
                    let bgClass = 'bg-yellow-500'; // Mặc định Medium (Vàng)
                    
                    if (task.priority === 'high') {
                        bgClass = 'bg-red-500'; // High (Đỏ)
                    } else if (task.priority === 'low') {
                        bgClass = 'bg-green-500'; // Low (Xanh lá)
                    }

                    // --- 4. TẠO THẺ HTML (Dùng Absolute Div làm thanh màu) ---
                    const card = document.createElement('div');

                    card.id = `task-card-${task.task_id}`;
                    
                    // Class cha: relative + overflow-hidden để chứa thanh màu
                    card.className = `relative bg-white p-3 rounded-lg shadow-sm border border-gray-200 mb-3 cursor-pointer hover:shadow-md transition-all overflow-hidden`;
                    
                    card.onclick = () => openTaskDetailModal(task.task_id);
                    
                    card.innerHTML = `
                        <!-- THANH MÀU BÊN TRÁI (Tuyệt đối) -->
                        <div class="absolute top-0 left-0 bottom-0 w-1.5 ${bgClass}"></div>

                        <!-- NỘI DUNG CARD (Thêm pl-2 để cách thanh màu ra) -->
                        <div class="pl-2">
                            <div class="font-medium text-sm text-gray-800 mb-2 line-clamp-2" title="${task.title}">
                                ${task.title}
                            </div>
                            
                            <div class="flex justify-between items-center">
                                <span class="text-[10px] font-bold text-gray-500 bg-gray-100 px-1.5 py-0.5 rounded">
                                    #${task.task_id}
                                </span>
                            </div>
                        </div>
                    `;
                    
                    col.appendChild(card);
                }
            });
            
            if(window.lucide) lucide.createIcons();
        }

        // --- UPDATE STATUS  ---
            async function updateTaskStatus(taskId, newStatus) {
            
            
            // 1. Tìm thẻ Card
            const cardId = `task-card-${taskId}`;
            const card = document.getElementById(cardId);
            
            if(!card) {
                console.error(`Không tìm thấy thẻ HTML có ID: ${cardId}`);
                return; 
            }

            // Hiệu ứng mờ
            card.style.opacity = '0.5';

            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
                
                // Gọi API
                const response = await fetch(`/api/projects/${projectId}/tasks/${taskId}`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-CSRF-TOKEN': token
                    },
                    body: JSON.stringify({ status: newStatus })
                });

                if(!response.ok) throw new Error('Update failed');

                

                // 2. Xác định cột đích
                let targetColId = 'todo-column';
                if (['done', 'completed'].includes(newStatus)) targetColId = 'done-column';
                else if (['in_progress', 'doing'].includes(newStatus)) targetColId = 'in_progress-column';

                const targetColumn = document.getElementById(targetColId);
                
                // 3. Di chuyển thẻ
                if(targetColumn) {
                    targetColumn.appendChild(card); // Tự động rút khỏi cột cũ và gắn vào cột mới
                    updateColumnCounts(); // Cập nhật số đếm
                    
                } else {
                    console.error(`Không tìm thấy cột đích: ${targetColId}`);
                }

            } catch (error) {
                console.error(error);
                alert('Failed to update status.');
            } finally {
                if(card) card.style.opacity = '1';
            }
        }

        function updateColumnCounts() {
            ['todo', 'in_progress', 'done'].forEach(id => {
                const col = document.getElementById(id + '-column');
                const count = document.getElementById(id + '-count');
                if(col && count) count.innerText = col.children.length;
            });
        }

        // --- HÀM XÓA TASK ---
        async function deleteTask(taskId) {
            if (!confirm('Are you sure you want to delete this task? This action cannot be undone.')) {
                return;
            }

            const deleteBtn = document.getElementById('btn-delete-task');
            if(deleteBtn) deleteBtn.classList.add('opacity-50', 'cursor-not-allowed');

            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
                const response = await fetch(`/api/projects/${projectId}/tasks/${taskId}`, {
                    method: 'DELETE',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-CSRF-TOKEN': token
                    }
                });

                if (!response.ok) throw new Error('Delete failed');

                // Xóa thành công
                // 1. Đóng modal
                closeTaskDetailModal();
                
                // 2. Xóa thẻ card khỏi giao diện
                const card = document.getElementById(`task-card-${taskId}`);
                if (card) {
                    card.remove();
                    updateColumnCounts(); // Cập nhật số đếm
                }
                
                // alert('Task deleted successfully');

            } catch (error) {
                console.error(error);
                alert('Failed to delete task.');
                if(deleteBtn) deleteBtn.classList.remove('opacity-50', 'cursor-not-allowed');
            }
        }

        function renderMembers(members) {
            projectMembersData = members;
            const list = document.getElementById('members-list');
            const select = document.getElementById('task-assignee-select'); // <--- Select Box
            const countLabel = document.getElementById('member-count');

            if(countLabel) countLabel.innerText = members.length;
            
            // Reset danh sách
            if(list) list.innerHTML = '';
            if(select) select.innerHTML = '<option value="">+ Add member...</option>';

            members.forEach(m => {
                const isManager = m.role === 'manager';
                const isSelf = m.customer_id === currentUserId;

                // 1. Render ra Sidebar (Code cũ của bạn)
                if (list && typeof memberInnerHtml === 'function') {
                    list.innerHTML += memberInnerHtml(m, isManager, isSelf);
                } else if (list) {
                    // Fallback nếu thiếu hàm memberInnerHtml
                    list.innerHTML += `<li class="p-2">${m.full_name}</li>`;
                }

                // 2. --- ĐOẠN CẦN THÊM MỚI ---
                // Thêm option vào Select Box để chọn người
                if (select) {
                    // Cách 1: Cộng dồn HTML (Nhanh gọn)
                    select.innerHTML += `<option value="${m.customer_id}">${m.full_name}</option>`;
                    
                    /* Cách 2: Tạo Element (An toàn hơn nếu tên có ký tự lạ)
                    const opt = document.createElement('option');
                    opt.value = m.customer_id;
                    opt.textContent = m.full_name;
                    select.appendChild(opt);
                    */
                }
            });
        }

        function memberInnerHtml(m, isManager, isSelf) {
            let actionButtons = '';
            const src = m.avatar || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(m.full_name) + '&background=random&color=fff';

            if (isOwner && currentUserId !== m.customer_id) {
                const memberBtnDisabled = !isManager ? 'disabled' : '';
                const memberBtnStyle = !isManager ? 'bg-gray-200 text-gray-700 cursor-not-allowed' : 'bg-blue-500 text-white hover:bg-blue-600';

                const managerBtnDisabled = isManager ? 'disabled' : '';
                const managerBtnStyle = isManager ? 'bg-gray-200 text-gray-700 cursor-not-allowed' : 'bg-green-500 text-white hover:bg-green-600';

                // Truyền toàn bộ object member dưới dạng JSON string
                const memberJson = JSON.stringify(m).replace(/"/g, '&quot;'); // escape " để nhúng vào HTML

                actionButtons = `
                    <div class="flex flex-col items-center ml-auto space-y-2">
                        <div class="flex flex-col border rounded-lg overflow-hidden text-xs font-semibold shadow-sm w-24">
                            <button 
                                class="change-role-btn px-2 py-1 w-full text-center border-b border-gray-200 ${memberBtnStyle}" 
                                data-member='${memberJson}'
                                data-role="Member"
                                ${memberBtnDisabled}
                                onclick="changeMemberRole(this, 'member')"
                            >
                                Member
                            </button>
                            <button 
                                class="change-role-btn px-2 py-1 w-full text-center ${managerBtnStyle}" 
                                data-member='${memberJson}'
                                data-role="Manager"
                                ${managerBtnDisabled}
                                onclick="changeMemberRole(this, 'manager')"
                            >
                                Manager
                            </button>
                        </div>

                        <button 
                            class="delete-member-btn p-1 text-red-500 hover:bg-red-100 rounded-full transition" 
                            title="Delete Member" 
                            data-member='${memberJson}'
                            onclick="deleteMember(this)"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.728-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm4 0a1 1 0 10-2 0v6a1 1 0 102 0V8z" clip-rule="evenodd" />
                            </svg>
                        </button>
                    </div>
                `;
            }

            return `
                <li class="flex items-center justify-between space-x-3 p-2 hover:bg-gray-50 rounded-lg transition cursor-default group" data-member-id="${m.customer_id}">
                    <div class="flex items-center space-x-3">
                        <img class="w-8 h-8 rounded-full object-cover border" src="${src}">
                        <div>
                            <p class="text-sm font-medium text-gray-900">${m.full_name} ${isSelf ? '(Bạn)' : ''}</p>
                            <p class="text-xs text-gray-500 capitalize">${m.role || 'Member'}</p>
                        </div>
                    </div>

                    ${actionButtons}
                </li>`;
        }

        function changeMemberRole(button, role) {
            const member = JSON.parse(button.dataset.member);
            window.api.updateMemberRole(projectId, member.customer_id, role).then(response => {
                if (response.success) {
                    member.role = role;
                    let newMemberHtml = memberInnerHtml(member, role === 'manager', member.customer_id === currentUserId, isOwner);
                    let memberItem = document.querySelector(`[data-member-id="${member.customer_id}"]`);
                    if (memberItem) {
                        memberItem.outerHTML = newMemberHtml;
                    }
                }
            });
        }

        // --- LOGIC MULTIPLE ASSIGNEES ---
        function addAssignee(selectElement) {
            const memberId = parseInt(selectElement.value);
            if (!memberId) return;

            // Kiểm tra nếu đã chọn rồi thì thôi
            if (selectedAssigneeIds.includes(memberId)) {
                selectElement.value = ""; // Reset select
                return;
            }

            // Thêm vào mảng
            selectedAssigneeIds.push(memberId);
            
            // Cập nhật giao diện & input hidden
            renderSelectedAssignees();
            
            // Reset select về mặc định để chọn người tiếp theo
            selectElement.value = "";
        }

        function removeAssignee(memberId) {
            // Lọc bỏ ID ra khỏi mảng
            selectedAssigneeIds = selectedAssigneeIds.filter(id => id !== memberId);
            renderSelectedAssignees();
        }

        function renderSelectedAssignees() {
            const container = document.getElementById('selected-assignees-container');
            const hiddenInput = document.getElementById('assignee_ids_input');
            
            if (!container || !hiddenInput) return;

            container.innerHTML = '';
            
            // Cập nhật value cho input hidden (dạng chuỗi "1,2,5")
            hiddenInput.value = selectedAssigneeIds.join(',');

            selectedAssigneeIds.forEach(id => {
                // Tìm thông tin member trong mảng dữ liệu gốc
                const member = projectMembersData.find(m => m.customer_id === id);
                if (member) {
                    const src = member.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(member.full_name)}&background=random&color=fff`;
                    
                    container.innerHTML += `
                        <div class="flex items-center bg-indigo-50 text-indigo-700 px-3 py-1 rounded-full text-xs font-bold border border-indigo-100 animate-fadeIn">
                            <img src="${src}" class="w-5 h-5 rounded-full mr-2 border border-white">
                            ${member.full_name}
                            <button type="button" onclick="removeAssignee(${id})" class="ml-2 text-indigo-400 hover:text-red-500 transition rounded-full hover:bg-indigo-100 p-0.5">
                                <i data-lucide="x" class="w-3 h-3"></i>
                            </button>
                        </div>
                    `;
                }
            });
            
            // Kích hoạt icon X
            if(window.lucide) lucide.createIcons();
        }

        function toggleAssignee(userId) { // Bỏ tham số element nếu không cần xử lý DOM trực tiếp ở đây
            userId = parseInt(userId);
            const index = selectedAssigneeIds.indexOf(userId); // <--- Chú ý tên biến

            if (index > -1) {
                selectedAssigneeIds.splice(index, 1);
            } else {
                selectedAssigneeIds.push(userId);
            }

            // Gọi hàm render để vẽ lại giao diện
            renderSelectedAssignees(); 
        }
        function deleteMember(button) {
            const member = JSON.parse(button.dataset.member);
            if (confirm('Are you sure you want to remove this member?')) {
                window.api.removeProjectMember(projectId, member.customer_id).then(response => {
                    if (response.success) {
                        let memberItem = document.querySelector(`[data-member-id="${member.customer_id}"]`);
                        if (memberItem) {
                            memberItem.remove();
                        }
                    }
                });
            }
        }

        async function addMember() {
            const memberId = document.getElementById('member-id-input').value;
            const role = document.getElementById('member-role-select').value;
            const addMemberBtn = document.getElementById('add-member-btn');
            if (memberId === '') return;

            try {
                if (addMemberBtn) {
                    addMemberBtn.disabled = true;
                    addMemberBtn.innerText = 'Adding...';
                    addMemberBtn.classList.add('bg-gray-200', 'text-gray-700', 'cursor-not-allowed');
                    addMemberBtn.classList.remove('bg-indigo-600', 'text-white', 'hover:bg-indigo-700');
                }
                const response = await window.api.addProjectMember(projectId, memberId, role);
                if (response.success) {
                    let newMember = response.data;
                    let newMemberHtml = memberInnerHtml(newMember, newMember.role === 'manager', newMember.customer_id === currentUserId, isOwner);
                    document.getElementById('members-list').innerHTML += newMemberHtml;
                }
            } catch (error) {
                console.error("Error adding member:", error);
                alert("Failed to add member.");
                closeAddMemberModal();
            } finally {
                memberId.value = '';
                role.value = 'member';

                if (addMemberBtn) {
                    addMemberBtn.disabled = false;
                    addMemberBtn.innerText = 'Add Member';
                    addMemberBtn.classList.remove('bg-gray-200', 'text-gray-700', 'cursor-not-allowed');
                    addMemberBtn.classList.add('bg-indigo-600', 'text-white', 'hover:bg-indigo-700');
                }
            }
        }

        function showAddMemberModal() {
            const modal = document.getElementById('addMemberModal');
            if(modal) modal.classList.remove('hidden');
        }

        function closeAddMemberModal() {
            const modal = document.getElementById('addMemberModal');
            if(modal) modal.classList.add('hidden');
        }

        async function renderChats(members) {
            
            // Project chat
            const response = await window.api.getLatestProjectMessage(projectId);
            if (!response.success) throw new Error('Failed to load data');
            const data = response.data[0];

            if(data.sender) {
                const isSelf = data.sender.customer_id === currentUserId;
                const created_at = data.created_at.split('.')[0].replace(' ', 'T') + 'Z';
                document.getElementById('project-chat-latest-sender').innerText = (isSelf ? 'You' : data.sender.full_name) + ":";
                document.getElementById('project-chat-latest-message').innerText = data.message ? data.message : 'File attached';
                document.getElementById('project-chat-latest-time').innerText = moment(created_at).fromNow();
            }

            document.getElementById('sidebar-chat').classList.remove('hidden');
            document.getElementById('chat-main-view').classList.add('hidden');

            // Private chats
            for (let member of members) {
                if(member.customer_id === currentUserId) continue;
                let response = await window.api.getLatestPrivateMessage(projectId, member.customer_id);
                if (!response.success) continue;

                let data = response.data[0];
                if (!data) continue;

                if(data.sender) {
                    let html = getPrivateChatinnerHTML(member, data);
                    document.getElementById('private-chats').innerHTML += html;
                }
            }
        }

        function getPrivateChatinnerHTML(otherUser, data) {
            customer_id = otherUser.customer_id;
            full_name = otherUser.full_name;

            sender = data.sender;
            avatar = otherUser.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(full_name)}&background=random&color=fff`;
            created_at = data.created_at.split('.')[0].replace(' ', 'T') + 'Z';
            message = data.message === "" ? "File attached" : data.message;
            isSelf = sender.customer_id === currentUserId;
            bold = isSelf && !data.is_read ? '' : 'font-bold';

            return `
                <div id="private-chat-${customer_id}" onclick="openPrivateChat(${customer_id}, '${full_name}', '${avatar}')" class="p-3 border-b border-gray-50 hover:bg-gray-50 cursor-pointer flex items-center space-x-3">
                    <div class="relative">
                        <img class="w-9 h-9 rounded-full" src="${avatar}" alt="${full_name}">
                        <span class="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-500 border-2 border-white rounded-full"></span>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="flex justify-between items-center">
                            <p class="text-sm font-medium text-gray-900">${full_name}</p>
                            <span class="text-xs text-gray-400">${moment(created_at).fromNow()}</span>
                        </div>
                        <p class="text-xs text-gray-500 truncate font-medium ${bold} text-gray-800">${isSelf ? 'You: ' : ''}${message}</p>
                    </div>
                </div>
            `;
        }

        // --- CHAT LOGIC ---

        async function openProjectChat() {
            otherUserId = null;
            document.getElementById('chat-list-view').classList.add('hidden');
            
            const chatMainView = document.getElementById('chat-main-view');
            const chatHeaderTitle = document.getElementById('chat-header-title');
            if(chatMainView) {
                chatMainView.classList.remove('hidden');
                chatMainView.classList.add('flex');
                if (chatHeaderTitle) {
                    chatHeaderTitle.textContent = 'General Project Chat';
                }
                
                let response = await window.api.getProjectMessages(projectId);
                if (!response.success) throw new Error('Failed to load data');
                let messages = response.data;

                renderNewMessages(messages);
                let pinMessages = await window.pinMessage.getPinMessage('project');
            }
        }

        async function openPrivateChat(userId, userName, userAvatar) {
            otherUserId = userId;
            document.getElementById('chat-header-avatar').src = userAvatar;
            document.getElementById('chat-header-avatar').classList.remove('hidden');
            document.getElementById('chat-list-view').classList.add('hidden');

            // Remove bold font from other private chats
            let customer = document.getElementById('private-chat-' + userId);
            if (customer) {
                let p = customer.querySelector('p.font-bold');
                if (p) {
                    p.classList.remove('font-bold');
                }
            }
            
            const chatMainView = document.getElementById('chat-main-view');
            const chatHeaderTitle = document.getElementById('chat-header-title');
            
            if (chatMainView) {
                chatMainView.classList.remove('hidden');
                chatMainView.classList.add('flex');
                if (chatHeaderTitle) {
                    chatHeaderTitle.textContent = userName;
                }

                let response = await window.api.getPrivateMessages(projectId, userId);
                if (!response.success) throw new Error('Failed to load data');
                let messages = response.data;

                renderNewMessages(messages);
                let pinMessages = await window.pinMessage.getPinMessage('private', userId);

                await window.api.markAsRead(messages[messages.length - 1].message_id);
            }
        }

        function closeChat() {
            const chatMainView = document.getElementById('chat-main-view');
            otherUserId = null;
            document.getElementById('chat-messages-container').innerText = '';
            document.getElementById('chat-loading-status').classList.remove('hidden');

            if(chatMainView) {
                chatMainView.classList.add('hidden');
                chatMainView.classList.remove('flex');
            }
            document.getElementById('chat-list-view').classList.remove('hidden');
            document.getElementById('chat-header-avatar').classList.add('hidden');
            document.getElementById('chat-messages-container').innerText = '';
        }

        function renderNewMessages(messages, loadMore = false) {
            const container = document.getElementById('chat-messages-container');
            if (!container) return;

            let tmp_container = '';

            if (!messages || messages.length === 0) {
                container.innerHTML = `<p class="text-center text-gray-500 py-4">Chưa có tin nhắn nào.</p>`;
                return;
            }

            messages.forEach(message => {
                const isSelf = message.sender.customer_id === currentUserId;
                
                const alignmentClass = isSelf ? 'justify-end' : 'justify-start';
                const messageBg = isSelf ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-800';
                const senderInfo = isSelf ? 'hidden' : 'block';

                const avatarUrl = message.sender.avatar 
                    ? message.sender.avatar 
                    : `https://ui-avatars.com/api/?name=${encodeURIComponent(message.sender.full_name)}&background=random&color=fff`;

                // --- Slove timezone issue ---
                const created_at = message.created_at.split('.')[0].replace(' ', 'T') + 'Z';
                const timeAgo = moment(created_at).fromNow();
                const fullTime = moment(created_at).local().format('HH:mm DD/MM/YYYY');
                
                // --- Render Resources (Tạo HTML cho từng item, đặt vào biến resourceItemsHtml) ---
                let resourceItemsHtml = '';
                if (message.resources && message.resources.length > 0) {
                    resourceItemsHtml = message.resources.map(res => {
                        const icon = res.type === 'image' ? 'image' : 'file-text';
                        const fileSize = (res.size / 1024 / 1024).toFixed(2); // MB
                        return `
                            <div class="flex items-center space-x-2 p-2 border border-dashed rounded-lg bg-white ${isSelf ? 'text-gray-800' : 'text-gray-600'}">
                                <i data-lucide="${icon}" class="w-4 h-4 flex-shrink-0 ${isSelf ? 'text-blue-400' : 'text-gray-400'}"></i>
                                <a href="/api/resources/${res.resource_id}/download/true" target="_blank" class="truncate text-xs font-medium hover:underline">
                                    ${res.file_name}
                                </a>
                                <span class="text-xs text-gray-400">(${fileSize}MB)</span>
                            </div>
                        `;
                    }).join('');
                }

                // Kiểm tra xem có nội dung tin nhắn và tài nguyên không
                const hasMessageText = message.message && message.message.trim() !== '';
                const hasResources = resourceItemsHtml !== '';
                
                // --- Render Message ---
                const messageHtml = `
                    <div class="message flex ${alignmentClass} space-x-3 mb-3" data-message-id="${message.message_id}">
                        <div class="w-8 h-8 rounded-full flex-shrink-0 ${isSelf ? 'order-2' : 'order-1'} ${senderInfo}">
                            <img class="w-8 h-8 rounded-full object-cover" src="${avatarUrl}" alt="${message.sender.full_name}">
                        </div>
                        
                        <div class="max-w-xs md:max-w-md ${isSelf ? 'order-1' : 'order-2'}">
                            <div class="text-xs text-gray-500 mb-1 ${isSelf ? 'text-right' : 'text-left'} ${senderInfo}">
                                ${message.sender.full_name} 
                                ${message.is_important ? '<i data-lucide="alert-triangle" class="w-3 h-3 text-red-500 inline ml-1"></i>' : ''}
                            </div>

                            ${hasMessageText ? `
                            <div class="p-3 rounded-xl shadow-sm relative ${messageBg} ${isSelf ? 'rounded-br-none' : 'rounded-tl-none'} group">
                                <div class="whitespace-pre-wrap">${message.message}</div>

                                <div class="text-right text-xs mt-1 opacity-70" title="${timeAgo}">
                                    ${fullTime}
                                </div>
                            </div>
                            ` : ''}

                            ${hasResources ? `
                            <div class="${hasMessageText ? 'mt-2' : ''} flex flex-col space-y-2"> 
                                ${resourceItemsHtml}
                            </div>
                            ` : ''}
                            
                            ${!hasMessageText && hasResources ? `
                            <div class="text-right text-xs mt-1 opacity-70" title="${timeAgo}">
                                ${fullTime}
                            </div>
                            ` : ''}
                        </div>
                    </div>
                `;
                
                tmp_container += messageHtml;
            });
            
            const chatLoadingStatus = document.getElementById('chat-loading-status');
            if(chatLoadingStatus) chatLoadingStatus.classList.add('hidden');
            
            if (loadMore) {
                container.innerHTML = tmp_container + container.innerHTML;
            } else {
                container.innerHTML += tmp_container;
            }

            // After render, create lucide icons
            if(window.lucide) lucide.createIcons();
            
            if (!loadMore) {
                // Scroll to bottom
                const scrollableContainer = document.getElementById('chat-messages-list');
                if (scrollableContainer) {
                    setTimeout(() => {
                        scrollableContainer.scrollTop = scrollableContainer.scrollHeight;
                    }, 0);
                }
            } else {
                // Scroll to the first elememt in chat-messages-list before load more
                const targetElement = document.querySelector(`.message[data-message-id="${messages[messages.length - 1].message_id}"]`);

                if (targetElement) {
                    targetElement.scrollIntoView({ 
                        block: 'start'
                    });
                }
            }
        }

        async function loadMoreMessages() {
            const container = document.getElementById('chat-messages-list');
            if (container.scrollTop === 0) {
                let messages = document.querySelectorAll('.message');
                if (messages[0].dataset.messageId == 1) return;

                if (otherUserId) {
                    response = await window.api.getPrivateMessages(projectId, otherUserId, messages.length);
                } else {
                    response = await window.api.getProjectMessages(projectId, messages.length);
                }

                if (!response.success) return;
                let newMessages = response.data;
                renderNewMessages(newMessages, true);
            }
        }

        document.getElementById('chat-send-form').addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                document.getElementById('chat-send-btn').click();
            }
        });

        document.getElementById('chat-messages-list').addEventListener('scroll', loadMoreMessages);

        function initializeChatDomElements() {
            chatFileInput = document.getElementById('chat-file-input');
            chatAttachBtn = document.getElementById('chat-attach-btn');
            chatPreviewContainer = document.getElementById('file-preview-container');
            chatInput = document.getElementById('chat-input');
            chatSendForm = document.getElementById('chat-send-form');

            setupChatAttachmentListeners();
            setupChatInputResize();
            setupChatFormSubmission();
        }

        function setupChatAttachmentListeners() {
            if (chatAttachBtn && chatFileInput) {
                chatAttachBtn.addEventListener('click', () => {
                    chatFileInput.click();
                });

                chatFileInput.addEventListener('change', () => {
                    renderFilePreview(chatFileInput.files);
                });
            }
        }

        function clearSelectedFiles() {
            if (chatFileInput) {
                chatFileInput.value = ''; 
            }
            renderFilePreview(null);
        }

        function renderFilePreview(files) {
            if (!chatPreviewContainer || !chatFileInput) return;

            if (!files || files.length === 0) {
                chatFileInput.value = ''; 
                chatPreviewContainer.classList.add('hidden');
                chatPreviewContainer.innerHTML = '';
                return;
            }

            chatPreviewContainer.classList.remove('hidden');
            
            let htmlContent = `<div class="flex items-center justify-between">`;
            
            // File List
            let fileListHtml = '<div><span class="text-xs text-gray-500 mr-2">Attached: </span>';
            
            // Show up to 3 files
            for (let i = 0; i < Math.min(files.length, 3); i++) {
                const file = files[i];
                const sizeMB = (file.size / 1024 / 1024).toFixed(2);
                
                fileListHtml += `
                    <span class="inline-flex items-center text-xs font-medium bg-blue-100 text-blue-800 rounded-full px-2 py-0.5 mr-1 mt-1">
                        ${file.name} (${sizeMB}MB)
                    </span>
                `;
            }
            
            if (files.length > 3) {
                fileListHtml += `<span class="text-xs text-gray-500 ml-1">và ${files.length - 3} more files.</span>`;
            }
            fileListHtml += '</div>';

            const clearButtonHtml = `
                <button type="button" id="chat-clear-files-btn" class="text-xs text-red-500 hover:text-red-700 transition font-medium flex items-center p-1 rounded hover:bg-red-50" title="Xóa tất cả file đã chọn">
                    <i data-lucide="x" class="w-3 h-3 mr-1"></i> Clear All
                </button>
            `;

            htmlContent += fileListHtml + clearButtonHtml + '</div>';

            chatPreviewContainer.innerHTML = htmlContent;
            
            // Create lucide icons
            if(window.lucide) lucide.createIcons();

            // Attach event listener to clear button
            const clearBtn = document.getElementById('chat-clear-files-btn');
            if (clearBtn) {
                clearBtn.addEventListener('click', clearSelectedFiles);
            }
        }

        function setupChatInputResize() {
            if (chatInput) {
                chatInput.addEventListener('input', () => {
                    chatInput.style.height = 'auto';
                    chatInput.style.height = (chatInput.scrollHeight) + 'px';
                });
            }
        }

        function setupChatFormSubmission() {
            if (chatSendForm) {
                chatSendForm.addEventListener('submit', async (e) => {
                    e.preventDefault();
                    const chatSendingStatus = document.getElementById('chat-sending-status');
                    if(chatSendingStatus) chatSendingStatus.classList.remove('hidden');
                    
                    const message = chatInput.value.trim();
                    const files = [...chatFileInput.files];

                    // Reset Form
                    chatInput.value = '';
                    chatFileInput.value = ''; 
                    renderFilePreview(null);
                    chatInput.style.height = '40px'; 

                    if (message === '' && files.length === 0) {
                        if(chatSendingStatus) chatSendingStatus.classList.add('hidden');
                        return;
                    }

                    const sendBtn = document.getElementById('chat-send-btn');
                    if (sendBtn) sendBtn.disabled = true;
                    try {
                        let response;
                        if (otherUserId) {
                            for (let i = 0; i < files.length; i++) {
                                const file = files[i];
                                response = await window.api.uploadFile(file, 'chat_private');
                                if (!response.success) throw new Error('Failed to upload file');

                                response = await window.api.sendPrivateMessage(projectId, otherUserId, message, response.data.resource_id);
                                if (!response.success) throw new Error('Failed to send message');

                                response = await window.api.getLatestPrivateMessage(projectId, otherUserId);
                                if (!response.success) throw new Error('Failed to load data');

                                renderNewMessages(response.data);
                            }

                            if (message !== '') {
                                response = await window.api.sendPrivateMessage(projectId, otherUserId, message);
                                if (!response.success) throw new Error('Failed to send message');

                                response = await window.api.getLatestPrivateMessage(projectId, otherUserId);
                                if (!response.success) throw new Error('Failed to load data');

                                renderNewMessages(response.data);
                            }
                        } else {
                            for (let i = 0; i < files.length; i++) {
                                const file = files[i];
                                response = await window.api.uploadFile(file, "chat_room");
                                if (!response.success) throw new Error('Failed to upload file');

                                response = await window.api.sendProjectMessage(projectId, message, response.data.resource_id);
                                if (!response.success) throw new Error('Failed to send message');

                                response = await window.api.getLatestProjectMessage(projectId);
                                if (!response.success) throw new Error('Failed to load data');

                                renderNewMessages(response.data);
                            }

                            if (message !== '') {
                                response = await window.api.sendProjectMessage(projectId, message);
                                if (!response.success) throw new Error('Failed to send message');

                                response = await window.api.getLatestProjectMessage(projectId);
                                if (!response.success) throw new Error('Failed to load data');

                                renderNewMessages(response.data);
                            }
                        }
                    } catch (error) {
                        console.error("Error sending message:", error);
                        alert("Failed to send message.");
                    } finally {
                        if (sendBtn) sendBtn.disabled = false;
                        if(chatSendingStatus) chatSendingStatus.classList.add('hidden');
                    }
                });
            }
        }

        // --- FILE LOGIC ---
        async function initializeFileDomElements() {
            fileListView = document.getElementById('sidebar-files');
            let response = await window.api.getProjectResources(projectId);
            if (response.success) {
                let files = response.data;

                for (let i = 0; i < files.length; i++) {
                    let file = files[i];
                    fileListView.innerHTML += getProjectFileHTML(file);
                }
            }
        }

        function getProjectFileHTML(file) {
            file = file.resources[0]
            const isSelf = file.uploaded_by.customer_id === currentUserId;
            let actionHtml = '';

            if (file.type === 'image') {
                actionHtml = `
                    <button 
                        onclick="previewImage('${file.resource_id}')" 
                        class="flex-1 flex items-center justify-center py-1 text-xs text-gray-600 bg-gray-50 hover:bg-gray-100 rounded">
                        <i data-lucide="eye" class="w-3 h-3 mr-1"></i> Preview
                    </button>
                `;
            }
            return `
                <div class="flex flex-col p-3 border border-gray-200 rounded-lg hover:border-indigo-300 transition group">
                    <div class="flex items-center space-x-3 mb-2">
                        <div class="w-8 h-8 bg-purple-100 text-purple-600 rounded flex items-center justify-center">
                            <i data-lucide="${file.type === 'image' ? 'image' : 'file-text'}" class="w-4 h-4"></i>
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-medium text-gray-800 truncate">${file.file_name}</p>
                            <p class="text-xs text-gray-500">${file.size} • ${isSelf ? 'You' : file.uploaded_by.full_name}</p>
                        </div>
                    </div>
                    <div class="flex space-x-2 mt-1 pt-2 border-t border-gray-50">
                        ${actionHtml}
                        <a 
                            href="/api/resources/${file.resource_id}/download/true" target="_blank"
                            class="flex-1 flex items-center justify-center py-1 text-xs text-gray-600 bg-gray-50 hover:bg-gray-100 rounded">
                            <i data-lucide="download" class="w-3 h-3 mr-1"></i> Download
                        </a>
                    </div>
                </div>
            `;
        }

        async function previewImage(resourceId) {
            const imagePreviewModal = document.getElementById('imagePreviewModal');
            const imagePreviewImg = document.getElementById('imagePreviewImg');
            imagePreviewImg.src = `/api/resources/${resourceId}/image`;
            imagePreviewModal.classList.remove('hidden');
        }

        function closeImagePreviewModal() {
            const imagePreviewModal = document.getElementById('imagePreviewModal');
            if(imagePreviewModal) imagePreviewModal.classList.add('hidden');
        }

        // --- MEMBER LOGIC ---
        async function removeMember(customerId) {}

        // --- INIT ---
        
        document.addEventListener('DOMContentLoaded', async () => {
            await loadProjectData();
            initializeChatDomElements();
            initializeFileDomElements();

            const createForm = document.getElementById('create-task-form');
            const createBtn = document.getElementById('btn-open-create-task');
    
            if (createBtn) {
                if (canEdit) {
                    // Nếu là Owner/Manager -> Hiện nút
                    createBtn.classList.remove('hidden');
                } else {
                    // Nếu là Member thường -> Ẩn nút
                    createBtn.classList.add('hidden');
                }
            }
            if (createForm) {
            // 1. XÓA BỎ 2 DÒNG CLONE NODE NÀY ĐI:
            // const newForm = createForm.cloneNode(true);
            // createForm.parentNode.replaceChild(newForm, createForm);

            // 2. Thay addEventListener bằng onsubmit (để tự động ghi đè listener cũ)
            createForm.onsubmit = async (e) => { // <--- Đổi thành createForm.onsubmit
                e.preventDefault(); 
                
                // Debug: Kiểm tra xem mảng này có dữ liệu chưa
                

                const submitBtn = createForm.querySelector('button[type="submit"]'); // Đổi newForm thành createForm
                const originalText = submitBtn.innerHTML;
                submitBtn.disabled = true;
                submitBtn.innerHTML = `<i data-lucide="loader-2" class="w-4 h-4 animate-spin mr-2"></i> Creating...`;
                
                if (typeof lucide !== 'undefined') lucide.createIcons();

                // Lấy dữ liệu
                const formData = new FormData(createForm); // Đổi newForm thành createForm
                const data = {
                    title: formData.get('title'),
                    description: formData.get('description'),
                    priority: formData.get('priority'),
                    due_date: formData.get('due_date'),
                    status: 'todo',
                    assignees: selectedAssigneeIds // Mảng ID thành viên
                };

                try {
                    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
                    
                    const response = await fetch(`/api/projects/${projectId}/tasks`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'X-CSRF-TOKEN': token
                        },
                        body: JSON.stringify(data)
                    });

                    if (!response.ok) {
                        const err = await response.json();
                        throw new Error(err.message || 'Failed to create task');
                    }

                    // Thành công
                    closeCreateTaskModal();
                    createForm.reset(); // Đổi newForm thành createForm
                    
                    // Quan trọng: Reset mảng và vẽ lại giao diện chọn người
                    selectedAssignees = []; 
                    if (typeof renderSelectedAssignees === 'function') {
                        renderSelectedAssignees(); 
                    }
                    
                    loadProjectData(); 

                } catch (error) {
                    console.error(error);
                    alert(error.message);
                } finally {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                }
            };
        } else {
            console.error("LỖI: Không tìm thấy form có id='create-task-form'");
        }

            // Đóng modal khi click ra ngoài background
            window.onclick = function(event) {
                const createModal = document.getElementById('createTaskModal');
                const detailModal = document.getElementById('taskDetailModal');
                if (event.target == createModal) closeCreateTaskModal();
                if (event.target == detailModal) detailModal.classList.add('hidden');
            }
        });

        function renderTaskFiles(files) {
            const container = document.getElementById('modal-task-files');
            if(!container) return;
            container.innerHTML = '';

            if (!files || files.length === 0) {
                container.innerHTML = '<li class="text-center text-xs text-gray-400 italic py-2">No files attached.</li>';
                return;
            }

            // Giả lập hiển thị file (Vì chưa có logic API)
            files.forEach(file => {
                container.innerHTML += `
                    <li class="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-100 group hover:border-indigo-200 transition">
                        <div class="flex items-center overflow-hidden">
                            <div class="p-2 bg-white rounded border border-gray-200 mr-3 text-indigo-500">
                                <i data-lucide="file" class="w-4 h-4"></i>
                            </div>
                            <div class="flex flex-col min-w-0">
                                <span class="text-sm font-medium text-gray-700 truncate">${file.content.resources[0].file_name || 'Unknown File'}</span>
                                <span class="text-[10px] text-gray-400">${file.content.resources[0].size || '0 KB'}</span>
                            </div>
                        </div>

                        <button onclick="deleteFile(${file.content.content_id})" class="text-gray-400 hover:text-red-500 hover:bg-red-50 p-1.5 rounded-full opacity-0 group-hover:opacity-100 transition" title="Delete file">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </li>
                `;
            });
            if(window.lucide) lucide.createIcons();
        }

        // Upload file to task
        document.getElementById('task-file-upload').addEventListener('change', async (e) => {
            const files = e.target.files;
            if (!files || files.length === 0) return;
            const taskId = document.getElementById('modal-task-id-display').dataset.taskId;

            const file = files[0];
            const response = await window.api.uploadFile(file, 'task', taskId);
            console.log(response);
            if (!response.success) throw new Error('Failed to upload file');

            // Reload task detail
            loadTaskDetail(taskId);
        });
    </script>
    
</body>
</html>
