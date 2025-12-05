<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class Customer extends Authenticatable implements JWTSubject
{
    /** @use HasFactory<\Database\Factories\CustomerFactory> */
    use HasFactory, Notifiable;

    /**
     * The table associated with the model.
     */
    protected $table = 'customers';

    /**
     * The primary key associated with the table.
     */
    protected $primaryKey = 'customer_id';

    /**
     * Indicates if the model should be timestamped.
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'full_name',
        'nickname',
        'email',
        'password',
        'avatar',
        'email_verified_at',
        'verification_token',
        'verification_token_expires_at',
        'reset_token',
        'reset_token_expires_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    public function projects()
    {
        return $this->belongsToMany(
            Project::class, 
            'project_members', 
            'member_id',       
            'project_id'       
        )->withPivot('role');
    }

    public function tasks()
    {
        return $this->belongsToMany(
            Task::class, 
            'task_assignees', 
            'assignee_id',    
            'task_id'         
        );
    }

    public function ownedProjects()
    {
        return $this->hasMany(Project::class, 'owner_id');
    }
}
