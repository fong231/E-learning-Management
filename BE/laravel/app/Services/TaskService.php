<?php

namespace App\Services;

use App\Models\Task;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class TaskService
{
    /**
     * Get all tasks for a project
     */
    public function getProjectTasks(int $projectId): array
    {
        $tasks = Task::where('project_id', $projectId)
            ->with([
                'creator:customer_id,full_name,email,avatar',
                'assignees:customer_id,full_name,email,avatar',
            ])
            ->orderBy('created_at', 'desc')
            ->get();

        return $tasks->map(function ($task) {
            return $this->formatTask($task);
        })->toArray();
    }

    /**
     * Get tasks grouped by status (for Kanban board)
     */
    public function getTasksByStatus(int $projectId): array
    {
        $tasks = $this->getProjectTasks($projectId);

        return [
            'todo' => array_filter($tasks, fn($task) => $task['status'] === 'todo'),
            'in_progress' => array_filter($tasks, fn($task) => $task['status'] === 'in_progress'),
            'done' => array_filter($tasks, fn($task) => $task['status'] === 'done'),
        ];
    }

    /**
     * Get task by ID
     */
    public function getTaskById(int $taskId): ?array
    {
        $task = Task::with([
            'creator:customer_id,full_name,email,avatar',
            'assignees:customer_id,full_name,email,avatar',
            'content.resources'
        ])->find($taskId);

        if (!$task) {
            return null;
        }

        return $this->formatTask($task);
    }

    /**
     * Create a new task
     */
    public function createTask(array $data, int $projectId, int $creatorId)
    {
        return DB::transaction(function () use ($data, $projectId, $creatorId) {
            // 1. Tạo Task vào DB
            $task = Task::create([
                'title' => $data['title'],
                'description' => $data['description'] ?? null,
                'priority' => $data['priority'] ?? 'medium',
                'status' => $data['status'] ?? 'todo',
                'due_date' => $data['due_date'] ?? null,
                'project_id' => $projectId,
                'create_by' => $creatorId,
            ]);

            Log::info('Task created: ' . $task->task_id);
            // 2. Gán người (Assignees)
            if (isset($data['assignees']) && is_array($data['assignees'])) {
                foreach ($data['assignees'] as $id) {
                    $task->assignees()->attach($id);
                }
            }

            // 3. Trả về dữ liệu Task đầy đủ (để Frontend vẽ lên luôn)
            return $this->getTaskById($task->task_id);
        });
    }

    public function updateTask(int $taskId, array $data)
    {
        $task = Task::find($taskId);
        
        if (!$task) {
            return null;
        }

        return DB::transaction(function () use ($task, $data) {
            $task->update([
                'title' => $data['title'] ?? $task->title,
                'description' => $data['description'] ?? $task->description,
                'priority' => $data['priority'] ?? $task->priority,
                'status' => $data['status'] ?? $task->status,
                'due_date' => $data['due_date'] ?? $task->due_date,
            ]);

            // Cập nhật danh sách người được giao (Sync)
            if (isset($data['assignees']) && is_array($data['assignees'])) {
                // Sync sẽ xóa những người cũ không có trong danh sách mới và thêm người mới
                $task->assignees()->sync($data['assignees']);
                
                // (Optional) Có thể thêm logic gửi thông báo cho người mới được assign ở đây
            }

            return $this->getTaskById($task->task_id);
        });
    }

    /**
     * Delete task
     */
    public function deleteTask(int $taskId): bool
    {
        $task = Task::find($taskId);
        
        if (!$task) {
            return false;
        }

        return $task->delete();
    }

    /**
     * Format task data
     */
    private function formatTask($task): array
    {
        return [
            'task_id' => $task->task_id,
            'title' => $task->title,
            'description' => $task->description,
            'project_id' => $task->project_id,
            'priority' => $task->priority,
            'status' => $task->status,
            'due_date' => $task->due_date,
            'created_at' => $task->created_at,
            'creator' => $task->creator ? [
                'customer_id' => $task->creator->customer_id,
                'full_name' => $task->creator->full_name,
                'email' => $task->creator->email,
                'avatar' => $task->creator->avatar,
            ] : null,
            'assignees' => $task->assignees->map(function ($assignee) {
                return [
                    'customer_id' => $assignee->customer_id,
                    'full_name' => $assignee->full_name,
                    'email' => $assignee->email,
                    'avatar' => $assignee->avatar,
                ];
            })->toArray(),
        ];
    }

    /**
     * Lấy thống kê số lượng task của một user cụ thể
     */
    public function getUserTaskStats(int $userId): array
    {
        // Query cơ bản: Lấy tất cả task mà user này ĐƯỢC GÁN (nằm trong bảng assignees)
        // Lưu ý: 'assignees' là tên relation trong Model Task
        $baseQuery = Task::whereHas('assignees', function ($query) use ($userId) {
            $query->where('customers.customer_id', $userId);
        });

        return [
            // Clone query để tránh bị ghi đè điều kiện
            'pending'     => (clone $baseQuery)->where('status', 'todo')->count(),
            'in_progress' => (clone $baseQuery)->where('status', 'in_progress')->count(),
            'done'        => (clone $baseQuery)->where('status', 'done')->count(),
        ];
    }
    
    public function getUpcomingDeadlines(int $userId): array
    {
        $tasks = \App\Models\Task::whereHas('assignees', function ($query) use ($userId) {
                $query->where('customers.customer_id', $userId);
            })
            ->where('status', '!=', 'done') // Chỉ lấy task chưa xong
            ->whereNotNull('due_date')      // Phải có ngày hết hạn
            ->whereDate('due_date', '>=', now()) // Deadline từ hôm nay trở đi
            ->with('project')               // Lấy kèm thông tin Project để hiển thị tên
            ->orderBy('due_date', 'asc')    // Xếp ngày gần nhất lên đầu
            ->limit(3)
            ->get();

        return $tasks->map(function ($task) {
            // Xử lý logic hiển thị ngày tháng
            $date = \Carbon\Carbon::parse($task->due_date);
            $label = '';
            $colorClass = '';
            $textClass = '';

            if ($date->isToday()) {
                $label = 'DUE TODAY';
                $colorClass = 'bg-red-100 text-red-600';
            } elseif ($date->isTomorrow()) {
                $label = 'TOMORROW';
                $colorClass = 'bg-orange-100 text-orange-600';
            } else {
                $label = $date->format('M d'); // Ví dụ: Nov 25
                $colorClass = 'bg-gray-100 text-gray-600';
            }

            return [
                'task_id' => $task->task_id,
                'title' => $task->title,
                'project_id' => $task->project_id,
                'project_name' => $task->project->name ?? 'Unknown Project',
                'label' => $label,
                'color_class' => $colorClass,
            ];
        })->toArray();
    }
}

