<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;

class ProfileController extends Controller
{
    public function show()
    {
        $user = Auth::user();
        
        $projectCount = method_exists($user, 'projects') ? $user->projects()->count() : 0;
        $completedTasksCount = method_exists($user, 'tasks') ? $user->tasks()->whereIn('status', ['done', 'completed'])->count() : 0;
        $pendingTasksCount = method_exists($user, 'tasks') ? $user->tasks()->whereNotIn('status', ['done', 'completed'])->count() : 0;

        

        return view('profile.show', compact('user', 'projectCount', 'completedTasksCount', 'pendingTasksCount'));
    }
}