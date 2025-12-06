<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProjectMember extends Model
{
    use HasFactory;
    protected $table = 'project_members';
    public $timestamps = false;

    protected $fillable = [
        'project_id',
        'member_id',
        'role',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class, 'project_id', 'project_id');
    }

    public function member()
    {
        return $this->belongsTo(Customer::class, 'member_id', 'customer_id'); 
    }
}
