<?php

namespace App\Services;

use App\Models\Project;
use App\Models\ProjectMember;
use Illuminate\Support\Facades\DB;

class ProjectService
{
    /**
     * Get all projects for a customer (owned or member)
     */
    public function getCustomerProjects(int $customerId): array
    {
        $projects = Project::where('owner_id', $customerId)
            ->orWhereHas('members', function ($query) use ($customerId) {
                $query->where('member_id', $customerId);
            })
            ->with([
                'owner', 
                'members' => function($query) {
                    $query->with('member');
                }
            ])
            ->get();

        return $projects->map(function ($project) {
            return [
                'project_id' => $project->project_id,
                'name' => $project->name,
                'description' => $project->description,
                'owner_id' => $project->owner_id,
                'created_at' => $project->created_at,
                'owner' => $project->owner ? [
                    'customer_id' => $project->owner->customer_id,
                    'full_name' => $project->owner->full_name,
                    'email' => $project->owner->email,
                    'avatar' => $project->owner->avatar,
                ] : null,
                'members' => $project->members->map(function ($member) {
                    $user = $member->member;
                    return [
                        'customer_id' => $user ? $user->customer_id : null,
                        'full_name' => $user ? $user->full_name : 'Unknown',
                        'email' => $user ? $user->email : '',
                        'avatar' => $user ? $user->avatar : null,
                        'role' => $member->role,
                    ];
                })->toArray(),
                'tasks_count' => $project->tasks()->count(),
            ];
        })->toArray();
    }

    /**
     * Get project by ID with full details
     */
    public function getProjectById(int $projectId): ?array
    {
        // Eager load relationships
        $project = Project::with([
            'owner', 
            'members.member',
            'tasks.assignees' 
        ])->find($projectId);

        if (!$project) {
            return null;
        }

        return [
            'project_id' => $project->project_id,
            'name' => $project->name,
            'description' => $project->description,
            'owner_id' => $project->owner_id,
            'created_at' => $project->created_at,
            
            // Owner info
            'owner' => $project->owner ? [
                'customer_id' => $project->owner->customer_id,
                'full_name' => $project->owner->full_name,
                'email' => $project->owner->email,
                'avatar' => $project->owner->avatar,
            ] : null,

            // Members info
            'members' => $project->members->map(function ($member) {
                $u = $member->member;
                return [
                    'customer_id' => $u ? $u->customer_id : null,
                    'full_name' => $u ? $u->full_name : 'Unknown',
                    'email' => $u ? $u->email : '',
                    'avatar' => $u ? $u->avatar : null,
                    'role' => $member->role,
                ];
            })->toArray(),

            'tasks' => $project->tasks->map(function ($task) {
                return [
                    'task_id' => $task->task_id,
                    'title' => $task->title,
                    'description' => $task->description,
                    'priority' => $task->priority,
                    'status' => $task->status, 
                    'due_date' => $task->due_date,
                    'created_at' => $task->created_at,
                    'assignees' => $task->assignees->map(function ($assignee) {
                        return [
                            'customer_id' => $assignee->customer_id,
                            'full_name' => $assignee->full_name,
                            'avatar' => $assignee->avatar,
                        ];
                    })->toArray(),
                ];
            })->toArray(),
        ];
    }

    /**
     * Get project members
     */
    public function getProjectMembers(int $projectId): array
    {
        $members = ProjectMember::where('project_id', $projectId)
            ->with('member')
            ->get();

        return $members->map(function ($member) {
            $u = $member->member;
            return [
                'customer_id' => $u ? $u->customer_id : null,
                'full_name' => $u ? $u->full_name : 'Unknown',
                'email' => $u ? $u->email : '',
                'avatar' => $u ? $u->avatar : null,
                'role' => $member->role,
            ];
        })->toArray();
    }

    /**
     * Add member to project
     */
    public function addProjectMember(int $projectId, int $memberId, string $role)
    {
        if (ProjectMember::where('project_id', $projectId)
            ->where('member_id', $memberId)
            ->exists()
        ) {
            return "Member already exists";
        }

        $member = ProjectMember::create([
            'project_id' => $projectId,
            'member_id' => $memberId,
            'role' => $role,
        ]);

        return [
            'customer_id' => $member->member_id,
            'full_name' => $member->member->full_name,
            'role' => $member->role,
        ];
    }

    /**
     * Remove member from project
     */
    public function removeProjectMember(int $projectId, int $memberId): bool
    {
        return ProjectMember::where('project_id', $projectId)
            ->where('member_id', $memberId)
            ->delete();
    }

    /**
     * Update member role
     */
    public function updateMemberRole(int $projectId, int $memberId, string $role): bool
    {
        return ProjectMember::where('project_id', $projectId)
            ->where('member_id', $memberId)
            ->update(['role' => $role]);
    }

    /**
     * Create a new project
     */
    public function createProject(array $data, int $ownerId): array
    {
        return DB::transaction(function () use ($data, $ownerId) {
            $project = Project::create([
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'owner_id' => $ownerId,
                'created_at' => now(),
            ]);

            // Add owner as manager
            ProjectMember::create([
                'project_id' => $project->project_id,
                'member_id' => $ownerId,
                'role' => 'manager',
            ]);

            return $this->getProjectById($project->project_id);
        });
    }

    /**
     * Update project
     */
    public function updateProject(int $projectId, array $data): ?array
    {
        $project = Project::find($projectId);
        
        if (!$project) {
            return null;
        }

        $project->update([
            'name' => $data['name'] ?? $project->name,
            'description' => $data['description'] ?? $project->description,
        ]);

        return $this->getProjectById($projectId);
    }

    /**
     * Delete project
     */
    public function deleteProject(int $projectId): bool
    {
        $project = Project::find($projectId);
        
        if (!$project) {
            return false;
        }

        return $project->delete();
    }

    /**
     * Check if user is project member or owner
     */
    public function isProjectMember(int $projectId, int $customerId): bool
    {
        $project = Project::find($projectId);
        
        if (!$project) {
            return false;
        }

        return $project->owner_id === $customerId || 
               $project->members()->where('member_id', $customerId)->exists();
    }
    
    /**
     * Lấy chức vụ (Role) của user: 'owner', 'manager', hoặc 'member'
     */
    public function getMemberRole(int $projectId, int $customerId)
    {
        $project = Project::find($projectId);
        
        if (!$project) {
            return null;
        }

        // 1. ƯU TIÊN CAO NHẤT: Nếu ID trùng với owner_id của bảng Project -> Là Owner
        if ($project->owner_id === $customerId) {
            return 'owner';
        }

        // 2. Nếu không phải Owner, kiểm tra trong bảng trung gian (project_members)
        // Lưu ý: Hãy đảm bảo bảng 'project_members' của bạn có cột 'role'
        $member = \Illuminate\Support\Facades\DB::table('project_members')
            ->where('project_id', $projectId)
            ->where('member_id', $customerId) // Code cũ bạn dùng member_id, check kỹ DB nhé
            ->first();

        if ($member) {
            // Trả về role (nếu bảng có cột role), nếu không có cột role thì mặc định là 'member'
            return isset($member->role) ? $member->role : 'member';
        }

        return null; // Không liên quan gì đến dự án này
    }
}

