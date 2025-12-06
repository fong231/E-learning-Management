<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ResourceService;
use App\Services\ProjectService;
use Illuminate\Http\Request;
use App\Helpers\AuthHelper;

class ResourceApiController extends Controller
{
    protected $resourceService;
    protected $projectService;

    public function __construct(ResourceService $resourceService, ProjectService $projectService)
    {
        $this->resourceService = $resourceService;
        $this->projectService = $projectService;
    }

    /**
     * Get all resources for a project
     */
    public function projectResources(Request $request, string $projectId)
    {
        $projectId = (int) $projectId;
        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if (!$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $resources = $this->resourceService->getProjectResources($projectId);

        return response()->json([
            'success' => true,
            'data' => $resources,
        ]);
    }

    /**
     * Get all resources for a task
     */
    public function taskResources(Request $request, string $projectId, string $taskId)
    {
        $projectId = (int) $projectId;
        $taskId = (int) $taskId;
        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if (!$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $resources = $this->resourceService->getTaskResources($taskId);

        return response()->json([
            'success' => true,
            'data' => $resources,
        ]);
    }

    /**
     * Get resources for a content
     */
    public function contentResources(int $contentId)
    {
        $resources = $this->resourceService->getContentResources($contentId);

        return response()->json([
            'success' => true,
            'data' => $resources,
        ]);
    }

    /**
     * Get resource image
     */
    public function resourceImage(Request $request, int $resourceId)
    {
        $resource = $this->resourceService->getResourceImage($resourceId);
        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            $projectId = $this->resourceService->getResourceProject($resourceId);
            if (!$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        if (!$resource) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found',
            ], 404);
        }

        return response($resource['file'])
            ->header('Content-Type', $resource['mime_type']);
    }

    /**
     * Upload file
     */
    public function upload(Request $request)
    {
        $validated = $request->validate([
            'file' => 'required|file|max:10240', // 10MB max
        ]);
        $contentType = $request->query('content_type');

        $customerId = AuthHelper::getCustomerId($request);
        
        $resource = $this->resourceService->uploadFile(
            $request->file('file'),
            $contentType,
            $customerId,
            $request->query('task_id')
        );

        return response()->json([
            'success' => true,
            'message' => 'File uploaded successfully',
            'data' => $resource,
        ], 201);
    }

    /**
     * Delete resource
     */
    public function destroy(int $resourceId)
    {
        $deleted = $this->resourceService->deleteResource($resourceId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Resource deleted successfully',
        ]);
    }

    /**
     * Get resource by ID
     */
    public function getResourceById(Request $request, string $resourceId, string $download)
    {
        $download = $download === 'true' ? true : false;
        $resourceId = (int) $resourceId;
        $projectId = $this->resourceService->getResourceProject($resourceId);
        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if (!$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $resource = $this->resourceService->getResourceById($resourceId, $download);

        if (!$resource) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found',
            ], 404);
        }

        if ($download) {
            return $resource;
        }

        return response()->json([
            'success' => true,
            'data' => $resource,
        ]);
    }
}

