<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Resource extends Model
{
    protected $primaryKey = 'resource_id';
    public $timestamps = false;

    protected $fillable = [
        'path',
        'type',
        'size',
        'file_name',
        'uploaded_by',
        'content_id',
        'created_at',
    ];

    public function uploadedBy()
    {
        return $this->belongsTo(Customer::class, 'uploaded_by', 'customer_id');
    }

    public function content()
    {
        return $this->belongsTo(Content::class, 'content_id', 'content_id');
    }
}
