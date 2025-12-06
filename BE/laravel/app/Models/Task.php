<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    protected $primaryKey = 'task_id';

    protected $fillable = [
        'title',
        'project_id',
        'description',
        'created_by',
        'priority',
        'status',
        'due_date',
        'created_at',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class, 'project_id', 'project_id');
    }

    public function creator()
    {
        return $this->belongsTo(Customer::class, 'created_by', 'customer_id');
    }

    public function assignees()
    {
        return $this->belongsToMany(Customer::class, 'task_assignees', 'task_id', 'assignee_id');
    }

    public function taskContent()
    {
        return $this->hasOne(TaskContent::class, 'task_id', 'task_id');
    }

    public function content()
{
    return $this->hasOneThrough(
        Content::class,
        TaskContent::class,
        'task_id',     // Foreign key on TaskContent
        'content_id',  // Foreign key on Content
        'task_id',     // Local key on Task
        'content_id'   // Local key on TaskContent
    );
}
}
