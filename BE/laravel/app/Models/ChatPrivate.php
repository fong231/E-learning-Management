<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatPrivate extends Model
{
    protected $primaryKey = 'message_id';

    protected $fillable = [
        'message',
        'project_id',
        'sender_id',
        'receiver_id',
        'content_id',
        'is_read',
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

    public function receiver()
    {
        return $this->belongsTo(Customer::class, 'receiver_id', 'customer_id');
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
