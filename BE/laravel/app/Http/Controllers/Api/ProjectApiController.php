<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ProjectService;
use Illuminate\Http\Request;
use App\Helpers\AuthHelper;

class ProjectApiController extends Controller
{
    protected $projectService;

    public function __construct(ProjectService $projectService)
    {
        $this->projectService = $projectService;
    }

    /**
     * Get all projects for authenticated customer
     */
    public function index(Request $request)
    {
        $customerId = AuthHelper::getCustomerId($request);
        $projects = $this->projectService->getCustomerProjects($customerId);

        return response()->json([
            'success' => true,
            'data' => $projects,
        ]);
    }

    /**
     * Get all members for a project
     */
    public function projectMembers(Request $request, int $projectId)
    {
        $members = $this->projectService->getProjectMembers($projectId);

        return response()->json([
            'success' => true,
            'data' => $members,
        ]);
    }

    /**
     * Add member to project
     */
    public function addProjectMember(Request $request, int $projectId)
    {
        $validated = $request->validate([
            'member_id' => 'required|exists:customers,customer_id',
            'role' => 'required|in:manager,member',
        ]);

        $member = $this->projectService->addProjectMember($projectId, $validated['member_id'], $validated['role']);

        return response()->json([
            'success' => true,
            'data' => $member,
        ]);
    }

    /**
     * Remove member from project
     */
    public function removeProjectMember(Request $request, int $projectId, int $memberId)
    {
        $this->projectService->removeProjectMember($projectId, $memberId);

        return response()->json([
            'success' => true,
            'message' => 'Member removed successfully',
        ]);
    }

    /**
     * Update member role
     */
    public function updateMemberRole(Request $request, int $projectId, int $memberId, string $role)
    {
        $this->projectService->updateMemberRole($projectId, $memberId, $role);

        return response()->json([
            'success' => true,
            'message' => 'Member role updated successfully',
        ]);
    }

    /**
     * Get project by ID
     */
    public function detail(Request $request, int $projectId)
    {
        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if ($customerId === null || !$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $project = $this->projectService->getProjectById($projectId);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $project,
        ]);
    }

    /**
     * Create new project
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $customerId = AuthHelper::getCustomerId($request);
        $project = $this->projectService->createProject($validated, $customerId);

        return response()->json([
            'success' => true,
            'message' => 'Project created successfully',
            'data' => $project,
        ], 201);
    }

    /**
     * Update project
     */
    public function update(Request $request, int $projectId)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if ($customerId === null || !$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $project = $this->projectService->updateProject($projectId, $validated);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Project updated successfully',
            'data' => $project,
        ]);
    }

    /**
     * Delete project
     */
    public function destroy(Request $request, int $projectId)
    {
        $customerId = AuthHelper::getCustomerId($request);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if ($customerId === null || !$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $deleted = $this->projectService->deleteProject($projectId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Project deleted successfully',
        ]);
    }
}

