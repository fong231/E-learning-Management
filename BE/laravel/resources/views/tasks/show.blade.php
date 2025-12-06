<div id="taskDetailModal" 
    class="hidden fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 
           animate-fadedIn">

    <!-- Modal Content -->
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-4xl h-[85vh] flex flex-col overflow-hidden 
                ring-1 ring-black/10 transform animate-scaleIn">

        <!-- Header -->
        <div class="flex justify-between items-center px-8 py-5 border-b border-slate-200 bg-white sticky top-0 z-10">
            
            <div class="flex items-center space-x-3">
                <span id="modal-task-id-display" 
                      class="px-3 py-1 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 tracking-wide">
                    #TSK-000
                </span>

                <span id="modal-task-priority" 
                      class="px-3 py-1 rounded-lg text-xs font-semibold bg-indigo-100 text-indigo-600 tracking-wide uppercase">
                    Loading...
                </span>
            </div>

            <div class="flex items-center space-x-1">
                <!-- DELETE BUTTON -->
                <button id="btn-delete-task" class="text-gray-400 hover:text-red-600 hover:bg-red-50 p-2 rounded-full transition hidden" title="Delete Task">
                    <i data-lucide="trash-2" class="w-5 h-5"></i>
                </button>

                <div class="h-6 w-px bg-gray-200 mx-2"></div>

                <button class="text-gray-400 hover:text-gray-600 hover:bg-gray-100 p-2 rounded-full transition" onclick="closeTaskDetailModal()">
                    <i data-lucide="x" class="w-6 h-6"></i>
                </button>
            </div>
        </div>

        <!-- Body -->
        <div class="flex-1 flex flex-col md:flex-row overflow-y-auto">

            <!-- LEFT -->
            <div class="md:w-2/3 p-8 border-r border-slate-200">

                <!-- Title -->
                <h1 id="modal-task-title" 
                    class="text-2xl font-semibold text-slate-900 mb-6 leading-snug tracking-tight">
                    Loading task...
                </h1>

                <!-- Description -->
                <div class="mb-10">
                    <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wide mb-3 flex items-center">
                        <i data-lucide="align-left" class="w-4 h-4 mr-2"></i> Description
                    </h3>

                    <div id="modal-task-description" 
                         class="text-slate-600 text-sm leading-relaxed whitespace-pre-line bg-slate-50 p-4 rounded-xl border border-slate-200">
                        No description provided.
                    </div>
                </div>

                <!-- Attachments -->
                <div>
                    <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wide mb-3 flex items-center">
                        <i data-lucide="paperclip" class="w-4 h-4 mr-2"></i> Attachments
                    </h3>

                    <!-- List -->
                    <ul id="modal-task-files" class="space-y-3 mb-5">
                        <li class="text-center text-xs text-slate-400 italic py-2">No files attached.</li>
                    </ul>

                    <!-- Upload -->
                    <label for="task-file-upload" 
                        class="flex items-center justify-center p-4 border-2 border-dashed border-slate-300 
                               rounded-xl text-sm font-medium text-slate-500 hover:border-indigo-500 
                               hover:text-indigo-600 hover:bg-indigo-50 cursor-pointer transition-all">
                        <i data-lucide="upload-cloud" class="w-4 h-4 mr-2"></i>
                        <span>Upload file</span>
                    </label>

                    <input type="file" id="task-file-upload" class="hidden">
                </div>
            </div>

            <!-- RIGHT -->
            <div class="md:w-1/3 bg-slate-50 p-7 space-y-7">

                <!-- Status -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase mb-2 tracking-wide">
                        Status
                    </label>
                    <select id="modal-task-status" 
                        class="w-full bg-white border border-slate-200 text-slate-700 text-sm rounded-xl 
                               p-3 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                        <option value="todo">To Do</option>
                        <option value="in_progress">In Progress</option>
                        <option value="done">Done</option>
                    </select>
                </div>

                <!-- Assignee -->
                <div>
                    <div class="mt-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Assigned to:</label>
                        
                        <div id="modal-task-assignees-container" class="space-y-1 max-h-40 overflow-y-auto pr-1">
                            </div>
                    </div>
                </div>

                <!-- Due date -->
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase mb-2 tracking-wide">
                        Due Date
                    </label>

                    <div class="flex items-center p-3 bg-white rounded-xl border border-slate-200 shadow-sm text-slate-700">
                        <i data-lucide="calendar" class="w-4 h-4 mr-2 text-slate-400"></i>
                        <span id="modal-task-duedate" class="text-sm font-medium">--/--/----</span>
                    </div>
                </div>

                <!-- Created -->
                <div class="border-t border-slate-300 pt-5 mt-5">
                    <p class="text-xs text-slate-500">
                        Created on 
                        <span id="modal-task-created" class="font-medium text-slate-600">...</span>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- Animations -->
<style>
@keyframes fadedIn {
    from { opacity: 0; }
    to   { opacity: 1; }
}
@keyframes scaleIn {
    from { transform: scale(.95); opacity: 0; }
    to   { transform: scale(1); opacity: 1; }
}
.animate-fadedIn { animation: fadedIn .18s ease-out; }
.animate-scaleIn { animation: scaleIn .2s ease-out; }
</style>
