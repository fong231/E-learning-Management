<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\Project;
use App\Models\ProjectMember;

Broadcast::channel('project.{projectId}', function ($user, $projectId) {
    // Check if user is owner
    $isOwner = Project::where('project_id', $projectId)
        ->where('owner_id', $user->customer_id)
        ->exists();

    // Check if user is member
    $isMember = ProjectMember::where('project_id', $projectId)
        ->where('member_id', $user->customer_id)
        ->exists();
    
    return $isOwner || $isMember;
});

Broadcast::channel('private.{customer_id}', function ($user, $customer_id) {
    return (int) $user->customer_id === (int) $customer_id;
});

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});
