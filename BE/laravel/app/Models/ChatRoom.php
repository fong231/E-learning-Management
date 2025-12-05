<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatRoom extends Model
{
    protected $primaryKey = 'message_id';

    protected $fillable = [
        'message',
        'project_id',
        'sender_id',
        'content_id',
        'is_important',
        'created_at',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class, 'project_id', 'project_id');
    }

    public function sender()
    {
        return $this->belongsTo(Customer::class, 'sender_id', 'customer_id');
    }

    public function content()
    {
        return $this->belongsTo(Content::class, 'content_id', 'content_id');
    }

    public function resources()
    {
        return $this->hasMany(Resource::class, 'content_id', 'content_id');
    }
}
