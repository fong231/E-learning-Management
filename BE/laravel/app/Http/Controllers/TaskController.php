<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Task;
use App\Models\Project;
use App\Helpers\AuthHelper;

class TaskController extends Controller
{
    public function detail(Task $task)
    {
        $task = Task::with('assignees', 'content.resources', 'creator')->find($task->task_id);
        return response()->json($task);
    }

    public function store(Request $request, Project $project)
    {
        // Check if user is member of project
        $customerId = AuthHelper::getCustomerId($request);
        $isMember = $project->members()->where('member_id', $customerId)->exists();
        
        if (!$isMember && $project->owner_id !== $customerId) {
            abort(403, 'Unauthorized');
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'priority' => 'nullable|in:low,medium,high',
            'status' => 'nullable|in:todo,in_progress,done',
            'due_date' => 'nullable|date',
        ]);

        $task = Task::create([
            'title' => $validated['title'],
            'project_id' => $project->project_id,
            'priority' => $validated['priority'] ?? 'medium',
            'status' => $validated['status'] ?? 'todo',
            'due_date' => $validated['due_date'] ?? null,
            'created_by' => $customerId,
        ]);

        return response()->json($task, 201);
    }

    public function update(Request $request, Task $task)
    {
        // Check if user is member of project
        $project = $task->project;
        $isMember = $project->members()->where('member_id', Auth::id())->exists();
        
        if (!$isMember && $project->owner_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        $validated = $request->validate([
            'title' => 'nullable|string|max:255',
            'priority' => 'nullable|in:low,medium,high',
            'status' => 'nullable|in:todo,in_progress,done',
            'due_date' => 'nullable|date',
        ]);

        $task->update($validated);

        return response()->json($task);
    }

    public function destroy(Task $task)
    {
        // Check if user is member of project
        $project = $task->project;
        $isMember = $project->members()->where('member_id', Auth::id())->exists();
        
        if (!$isMember && $project->owner_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        $task->delete();

        return response()->json(['message' => 'Task deleted successfully']);
    }
}
