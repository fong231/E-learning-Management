<div class="task-card priority-{{ $task->priority ?? 'medium' }} bg-white p-3 rounded-lg border border-gray-200 hover:shadow-md transition cursor-pointer mb-3 border-l-4 
    {{ $task->priority == 'high' ? 'border-l-red-500' : ($task->priority == 'low' ? 'border-l-green-500' : 'border-l-yellow-500') }}" 
    onclick="openTaskDetailModal({{ $task->task_id }})">
    
    <div class="flex justify-between items-start mb-1">
        <p class="font-medium text-gray-800 text-sm leading-tight line-clamp-2">{{ $task->title }}</p>
    </div>
    
    <div class="flex justify-between items-center mt-2">
        <span class="text-[10px] font-semibold px-1.5 py-0.5 rounded bg-gray-100 text-gray-500 border border-gray-200">
            #{{ $task->task_id }}
        </span>
        
        {{-- Avatar người được giao việc (Assignee) --}}
        <div class="flex items-center space-x-2">
            @if($task->priority == 'high')
                <i data-lucide="flag" class="w-3 h-3 text-red-500 fill-current"></i>
            @endif
            
            @if($task->assignees->count() > 0)
                @php $assignee = $task->assignees->first(); @endphp
                <img class="w-5 h-5 rounded-full border border-white object-cover" 
                     src="{{ $assignee->avatar ? asset($assignee->avatar) : 'https://ui-avatars.com/api/?name=' . urlencode($assignee->full_name) . '&background=random&color=fff' }}" 
                     alt="{{ $assignee->full_name }}" title="Assigned to: {{ $assignee->full_name }}">
            @else
                <span class="w-5 h-5 rounded-full bg-gray-200 border border-white flex items-center justify-center text-[10px] text-gray-500">?</span>
            @endif
        </div>
    </div>
</div>