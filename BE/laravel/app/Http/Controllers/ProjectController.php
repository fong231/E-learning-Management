<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth; 
use App\Models\Customer;
use App\Models\Project;
use App\Models\ProjectMember;
use App\Services\TaskService;
use App\Helpers\AuthHelper;

class ProjectController extends Controller
{
    /**
     * Dashboard: Chỉ trả về View rỗng.
     * Javascript trong View sẽ gọi API để lấy danh sách dự án.
     */
    protected $taskService;

    public function __construct(TaskService $taskService)
    {
        $this->taskService = $taskService;
    }

    public function dashboard()
    {
        $user = Auth::user();

        if (!$user) {
            return redirect()->route('login');
        }

        $userId = $user->customer_id; // Lấy ID người dùng

        // Lấy thống kê Task (Pending, In Progress, Done)
        // Gọi hàm vừa viết bên TaskService
        $taskStats = $this->taskService->getUserTaskStats($userId);

        // Tính tổng số dự án (Total Projects)
        // Logic: Dự án mình làm chủ HOẶC Dự án mình là thành viên
        $totalProjects = Project::where('owner_id', $userId)
            ->orWhereHas('members', function($query) use ($userId) {
                $query->where('project_members.member_id', $userId); 
            })->count();
        
        $upcomingTasks = $this->taskService->getUpcomingDeadlines($userId);
        // Truyền dữ liệu sang View
        return view('dashboard', [
            'pendingCount'    => $taskStats['pending'],
            'inProgressCount' => $taskStats['in_progress'],
            'doneCount'       => $taskStats['done'], 
            'totalProjects'   => $totalProjects,
            'upcomingTasks'   => $upcomingTasks
        ]);
    }

    /**
     * Show Project: Chỉ trả về View rỗng kèm ID.
     */
    public function show(Project $project)
    {
        $user = Auth::user();
        $userId = $user->customer_id;

        // Check quyền truy cập 
        $isMember = $project->members()->where('member_id', $userId)->exists();
        if (!$isMember && $project->owner_id !== $userId) {
            abort(403, 'Unauthorized');
        }

        

        // Trả về view, JS sẽ gọi API lấy tasks và members sau
        return view('projects.show', compact('project'));
    }

    // --- CÁC HÀM XỬ LÝ FORM (Submit truyền thống) ---
    
    public function store(Request $request)
    {
        $customerId = AuthHelper::getCustomerId($request);
        $user = Customer::find($customerId);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'member_ids' => 'nullable|string',
        ]);

        $project = Project::create([
            'name' => $validated['name'],
            'description' => $validated['description'] ?? null,
            'owner_id' => $user->customer_id,
        ]);

        // Thêm Members
        if (!empty($request->member_ids)) {
            $memberIds = explode(',', $request->member_ids);
            foreach ($memberIds as $memberId) {
                $memberId = trim($memberId);
                if (is_numeric($memberId) && $memberId != $user->customer_id) {
                    try {
                        ProjectMember::create([
                            'project_id' => $project->project_id,
                            'member_id' => $memberId,
                            'role' => 'member',
                        ]);
                    } catch (\Exception $e) { continue; }
                }
            }
        }

        return redirect()->route('dashboard')->with('success', 'Project created successfully');
    }

    public function update(Request $request, Project $project)
    {
        $customerId = AuthHelper::getCustomerId($request);

        if ($project->owner_id !== $customerId) {
            abort(403, 'Unauthorized');
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $project->update($validated);

        return redirect()->route('projects.show', $project)->with('success', 'Project updated successfully');
    }

    public function destroy(Request $request, Project $project)
    {
        $customerId = AuthHelper::getCustomerId($request);

        if ($project->owner_id !== $customerId) {
            abort(403, 'Unauthorized');
        }

        $project->delete();

        return redirect()->route('dashboard')->with('success', 'Project deleted successfully');
    }

    // --- CÁC HÀM NOTIFICATION  ---

    public function markAllNotificationsRead()
    {
        $user = Auth::user();
        $user->unreadNotifications->markAsRead();
        return back()->with('success', 'All notifications marked as read.');
    }

    public function allNotifications()
    {
        $user = Auth::user();
        $allNotifications = $user->notifications()->paginate(15);
        return view('notifications.index', compact('allNotifications'));
    }
    
    public function markNotificationAsRead($id)
    {
        $notification = Auth::user()->notifications()->where('id', $id)->first();
        if ($notification) {
            $notification->markAsRead();
            return redirect($notification->data['link'] ?? route('dashboard'));
        }
        return back();
    }
}