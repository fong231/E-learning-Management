<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TaskService;
use App\Services\ProjectService;
use Illuminate\Http\Request;
use App\Helpers\AuthHelper;

class TaskApiController extends Controller
{
    protected $taskService;
    protected $projectService;

    public function __construct(TaskService $taskService, ProjectService $projectService)
    {
        $this->taskService = $taskService;
        $this->projectService = $projectService;
    }

    /**
     * Get all tasks for a project
     */
    public function index(Request $request, int $projectId)
    {
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

        $tasks = $this->taskService->getProjectTasks($projectId);

        return response()->json([
            'success' => true,
            'data' => $tasks,
        ]);
    }

    /**
     * Get tasks grouped by status (Kanban board)
     */
    public function kanban(Request $request, int $projectId)
    {
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

        $tasks = $this->taskService->getTasksByStatus($projectId);

        return response()->json([
            'success' => true,
            'data' => $tasks,
        ]);
    }

    /**
     * Get task by ID
     */
    public function show(Request $request, int $projectId, int $taskId)
    {
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

        $task = $this->taskService->getTaskById($taskId);

        if (!$task) {
            return response()->json([
                'success' => false,
                'message' => 'Task not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $task,
        ]);
    }

    /**
     * Create new task
     */
    public function store(Request $request, int $projectId)
    {
        $customerId = AuthHelper::getCustomerId($request);

        // 1. Lấy vai trò (Role) của người dùng
        // (Đảm bảo bạn đã thêm hàm getMemberRole vào ProjectService như hướng dẫn trước)
        $role = $this->projectService->getMemberRole($projectId, $customerId);

        // 2. Kiểm tra: Chỉ cho phép 'owner' hoặc 'manager'
        if (!in_array($role, ['owner', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền tạo Task (Chỉ Owner/Manager).',
            ], 403);
        }

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if (!$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'priority' => 'sometimes|in:low,medium,high',
            'description' => 'nullable|string',
            'status' => 'sometimes|in:todo,in_progress,done',
            'due_date' => 'nullable|date|after_or_equal:today',
            'assignees' => 'nullable|array',
            'assignees.*' => 'exists:customers,customer_id',
        ]);

        $task = $this->taskService->createTask($validated, $projectId, $customerId);

        return response()->json([
            'success' => true,
            'message' => 'Task created successfully',
            'data' => $task,
        ], 201);
    }

    /**
     * Update task
     */
    public function update(Request $request, int $projectId, int $taskId)
    {
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

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'priority' => 'sometimes|in:low,medium,high',
            'status' => 'sometimes|in:todo,in_progress,done',
            'due_date' => 'nullable|date',
            'assignees' => 'nullable|array',
            'assignees.*' => 'exists:customers,customer_id',
        ]);

        $task = $this->taskService->updateTask($taskId, $validated);

        if (!$task) {
            return response()->json([
                'success' => false,
                'message' => 'Task not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Task updated successfully',
            'data' => $task,
        ]);
    }

    /**
     * Delete task
     */
    public function destroy(Request $request, int $projectId, int $taskId)
    {
        $customerId = AuthHelper::getCustomerId($request);
        
        // 1. Lấy vai trò của người đang thực hiện thao tác
        $role = $this->projectService->getMemberRole($projectId, $customerId);

        // 2. Kiểm tra quyền: Chỉ cho phép 'owner' hoặc 'manager'
        // Nếu $role không nằm trong danh sách cho phép -> Báo lỗi 403
        if (!in_array($role, ['owner', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Permission denied. Only Manager or Owner can delete tasks.',
            ], 403);
        }

        // 3. Tiến hành xóa
        $deleted = $this->taskService->deleteTask($taskId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Task not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Task deleted successfully',
        ]);
    }
}

