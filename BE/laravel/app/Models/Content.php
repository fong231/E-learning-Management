<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Content extends Model
{
    protected $primaryKey = 'content_id';
    public $timestamps = false;

    protected $fillable = [
        'type',
    ];

    public function resources()
    {
        return $this->hasMany(Resource::class, 'content_id', 'content_id');
    }

    public function task()
    {
        return $this->hasOneThrough(
            Task::class,
            TaskContent::class,
            'content_id', // task_contents.content_id
            'task_id',    // tasks.task_id
            'content_id', // contents.content_id
            'task_id'     // task_contents.task_id
        );
    }

    public function taskContent()
    {
        return $this->hasOne(TaskContent::class, 'content_id', 'content_id');
    }

    public function chatRoom()
    {
        return $this->belongsTo(ChatRoom::class, 'content_id', 'content_id');
    }

    public function chatPrivate()
    {
        return $this->belongsTo(ChatPrivate::class, 'content_id', 'content_id');
    }
}
