<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class TaskAssigned extends Notification
{
    use Queueable;

    protected $task;

    // Nhận dữ liệu Task truyền vào
    public function __construct($task)
    {
        $this->task = $task;
    }

    // Chọn kênh gửi là 'database'
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    // Định nghĩa dữ liệu sẽ lưu vào bảng 'notifications' trong DB
    public function toArray(object $notifiable): array
    {
        return [
            'title' => 'New Task Assigned',
            'message' => 'You have been assigned to task: ' . $this->task->title,
            'task_id' => $this->task->task_id,
            'project_id' => $this->task->project_id ?? null, // Nếu có
            'link' => route('projects.show', $this->task->project_id), // Link để click vào
            'icon' => 'check-square', // Tên icon hiển thị
            'color' => 'text-blue-500',
        ];
    }
}