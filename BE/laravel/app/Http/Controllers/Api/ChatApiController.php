<?php

namespace App\Http\Controllers\Api;

use App\Events\GroupMessageSent;
use App\Events\PrivateMessageSent;
use App\Http\Controllers\Controller;
use App\Services\ChatService;
use App\Services\ProjectService;
use App\Helpers\AuthHelper;
use Illuminate\Http\Request;

class ChatApiController extends Controller
{
    protected $chatService;
    protected $projectService;

    public function __construct(ChatService $chatService, ProjectService $projectService)
    {
        $this->chatService = $chatService;
        $this->projectService = $projectService;
    }

    /**
     * Get latest project message
     */
    public function latestProjectMessage(Request $request, int $projectId)
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

        $messages = $this->chatService->getProjectMessages($projectId, 0, 1);

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Get latest private message
     */
    public function latestPrivateMessage(Request $request, int $projectId, int $otherUserId)
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

        $messages = $this->chatService->getPrivateMessages($customerId, $otherUserId, $projectId, 0, 1);

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Get project chat messages
     */
    public function projectMessages(Request $request, int $projectId)
    {
        $customerId = AuthHelper::getCustomerId($request);

        $offet = $request->query('offset', 0);
        $limit = $request->query('limit', 30);

        if (AuthHelper::isApiKeyAuth($request) === false) {
            // Check if user is member
            if (!$this->projectService->isProjectMember($projectId, $customerId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
        }

        $messages = $this->chatService->getProjectMessages($projectId, $offet, $limit);

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Get private chat messages
     */
    public function privateMessages(Request $request, int $projectId, int $otherUserId)
    {
        $offset = $request->query('offset', 0);
        $limit = $request->query('limit', 30);

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

        $messages = $this->chatService->getPrivateMessages($customerId, $otherUserId, $projectId, $offset, $limit);

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Send project chat message
     */
    public function sendProjectMessage(Request $request, int $projectId)
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
            'content_id' => 'required_without:message|nullable|exists:contents,content_id',
            'message' => 'required_without:content_id|nullable|string',
        ]);

        $message = $this->chatService->sendProjectMessage(
            $projectId,
            $customerId,
            $validated['message'] ?? '',
            $validated['content_id'] ?? null,
        );

        event(new GroupMessageSent($message, $projectId));

        return response()->json([
            'success' => true,
            'message' => 'Message sent successfully',
            'data' => $message,
        ], 201);
    }

    /**
     * Send private message
     */
    public function sendPrivateMessage(Request $request, int $projectId, int $otherUserId)
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
            'content_id' => 'required_without:message|nullable|exists:contents,content_id',
            'message' => 'required_without:content_id|nullable|string',
        ]);

        $message = $this->chatService->sendPrivateMessage(
            $projectId,
            $customerId,
            $otherUserId,
            $validated['message'] ?? '',
            $validated['content_id'] ?? null,
        );

        event(new PrivateMessageSent($message));

        return response()->json([
            'success' => true,
            'message' => 'Message sent successfully',
            'data' => $message,
        ], 201);
    }

    /**
     * Mark message as read
     */
    public function markAsRead(Request $request, int $messageId)
    {
        $customerId = AuthHelper::getCustomerId($request);
        $success = $this->chatService->markAsRead($customerId, $messageId);

        return response()->json([
            'success' => true,
            'message' => 'Message marked as read',
        ]);
    }

    /**
     * Pin message
     */
    public function pinMessage(Request $request, int $messageId, string $type)
    {
        if ($type === 'private') {
            $success = $this->chatService->pinPrivateMessage($messageId);
        } else {
            $success = $this->chatService->pinProjectMessage($messageId);
        }

        if (!$success) {
            return response()->json([
                'success' => false,
                'message' => 'Message not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Message pinned',
        ]);
    }

    /**
     * Unpin message
     */
    public function unpinMessage(Request $request, int $messageId, string $type)
    {
        if ($type === 'private') {
            $success = $this->chatService->unpinPrivateMessage($messageId);
        } else {
            $success = $this->chatService->unpinProjectMessage($messageId);
        }

        if (!$success) {
            return response()->json([
                'success' => false,
                'message' => 'Message not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Message unpinned',
        ]);
    }

    /**
     * Get pinned message from project chat
     */
    public function getPinMessageProject(Request $request, int $projectId)
    {
        $customerId = AuthHelper::getCustomerId($request);
        $messages = $this->chatService->getPinMessageProject($projectId, $customerId);

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Get pinned message from private chat
     */
    public function getPinMessagePrivate(Request $request, int $projectId, int $otherUserId)
    {
        $customerId = AuthHelper::getCustomerId($request);
        $messages = $this->chatService->getPinMessagePrivate($projectId, $customerId, $otherUserId);

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Search messages by content
     */
    public function searchMessages(Request $request, string $projectId)
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

        $query = $request->query('query');
        $otherUserId = $request->query('other_user_id');

        if ($otherUserId) {
            $messages = $this->chatService->searchPrivateMessages($projectId, $query, $customerId, $otherUserId);
        } else {
            $messages = $this->chatService->searchMessages($projectId, $query);
        }

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }
}

