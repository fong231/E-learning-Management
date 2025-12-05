<?php

namespace App\Services;

use App\Models\Resource;
use App\Models\TaskContent;
use App\Models\Content;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;

class ResourceService
{
    /**
     * Get all resources for a project
     */
    public function getProjectResources(int $projectId): array
    {
        // Get all tasks resources for this project via TaskContent -> content -> resource
        $resources = Content::where('type', 'task')
            ->whereHas('task', function ($query) use ($projectId) {
                $query->where('project_id', $projectId);
            })
            ->with(['resources' => function ($query) {
                $query->with(['uploadedBy:customer_id,full_name,email,avatar'])
                      ->orderBy('created_at', 'desc');
            }])
            ->get();

        return $resources->toArray();
    }

    public function getTaskResources(int $taskId): array
    {
        // Get all resources for this task via TaskContent -> content -> resource
        $resources = TaskContent::where('task_id', $taskId)
            ->with(['content' => function ($query) {
                $query->with(['resources' => function ($q) {
                    $q->with(['uploadedBy:customer_id,full_name,email,avatar'])
                      ->orderBy('created_at', 'desc');
                }]);
            }])
            ->get();
        
        return $resources->toArray();
    }

    /**
     * Get resources for a specific content
     */
    public function getContentResources(int $contentId): array
    {
        $resources = Resource::where('content_id', $contentId)
            ->with(['uploadedBy:customer_id,full_name,email,avatar'])
            ->orderBy('created_at', 'desc')
            ->get();

        return $resources->map(function ($resource) {
            return $this->formatResource($resource);
        })->toArray();
    }

    /**
     * Get project where resource belongs to
     */
    public function getResourceProject(int $resourceId): ?int
    {
        $resource = Resource::find($resourceId);
        
        if (!$resource) {
            return null;
        }

        if ($resource->content->type === 'task') {
            return $resource->content->task->project_id;
        } elseif ($resource->content->type === 'chat_room') {
            return $resource->content->chatRoom->project_id;
        } elseif ($resource->content->type === 'chat_private') {
            return $resource->content->chatPrivate->project_id;
        }

        return null;
    }

    /**
     * Upload a file
     */
    public function uploadFile(UploadedFile $file, string $contentType, int $uploadedBy, ?int $taskId = null): array
    {
        // Store file in storage/app/private
        $path = $file->store('resources', 'private');
        
        // Determine file type
        $mimeType = $file->getMimeType();
        $type = str_starts_with($mimeType, 'image/') ? 'image' : 'file';

        $content = Content::create([
            'type' => $contentType,
        ]);
        $contentId = $content->content_id;

        if ($contentType === 'task') {
            TaskContent::create([
                'task_id' => $taskId,
                'content_id' => $contentId,
            ]);
        }

        $resource = Resource::create([
            'path' => $path,
            'type' => $type,
            'size' => $file->getSize(),
            'file_name' => $file->getClientOriginalName(),
            'uploaded_by' => $uploadedBy,
            'content_id' => $contentId,
            'created_at' => now(),
        ]);

        return $this->formatResource($resource->load('uploadedBy'));
    }

    /**
     * Delete a resource
     */
    public function getResourceImage(int $resourceId)
    {
        $resource = Resource::find($resourceId);
        
        if (!$resource) {
            return null;
        }

        return [
            'mime_type' => $resource->mime_type,
            'file' => Storage::get($resource->path),
        ];
    }

    /**
     * Delete a resource
     */
    public function deleteResource(int $resourceId): bool
    {
        $resource = Resource::find($resourceId);
        
        if (!$resource) {
            return false;
        }

        // Delete file from path storage/app/private/resources
        Storage::disk('private')->delete($resource->path);

        return $resource->delete();
    }

    /**
     * Get resource by ID
     */
    public function getResourceById(int $resourceId, bool $download)
    {
        $resource = Resource::with(['uploadedBy:customer_id,full_name,email,avatar'])
            ->find($resourceId);

        if (!$resource) {
            return null;
        }

        if ($download == true) {
            return Storage::download($resource->path, $resource->file_name);
        }

        return $this->formatResource($resource);
    }

    /**
     * Format resource data
     */
    private function formatResource($resource): array
    {
        return [
            'resource_id' => $resource->resource_id,
            'file_name' => $resource->file_name,
            'path' => $resource->path,
            'url' => Storage::url($resource->path),
            'type' => $resource->type,
            'size' => $resource->size,
            'created_at' => $resource->created_at,
            'uploaded_by' => $resource->uploadedBy ? [
                'customer_id' => $resource->uploadedBy->customer_id,
                'full_name' => $resource->uploadedBy->full_name,
                'email' => $resource->uploadedBy->email,
                'avatar' => $resource->uploadedBy->avatar,
            ] : null,
        ];
    }
}

