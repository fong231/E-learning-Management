<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TaskContent extends Model
{
    protected $primaryKey = 'task_id';
    public $timestamps = false;

    protected $fillable = [
        'task_id',
        'content_id',
    ];
    
    public function task()
    {
        return $this->belongsTo(Task::class, 'task_id', 'task_id');
    }

    public function content()
    {
        return $this->belongsTo(Content::class, 'content_id', 'content_id');
    }
}
