<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $primaryKey = 'project_id';
    public $timestamps = false;

    protected $fillable = [
        'name',
        'description',
        'owner_id',
        'created_at',
    ];

    public function owner()
    {
        return $this->belongsTo(Customer::class, 'owner_id', 'customer_id');
    }

    public function members() 
    {
        return $this->hasMany(ProjectMember::class, 'project_id', 'project_id');
    }

    public function tasks()
    {
        return $this->hasMany(Task::class, 'project_id', 'project_id');
    }

    public function chatMessages()
    {
        return $this->hasMany(ChatRoom::class, 'project_id', 'project_id');
    }
}
