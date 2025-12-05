<?php

namespace App\Services;

use App\Models\ChatRoom;
use App\Models\ChatPrivate;
use Illuminate\Support\Facades\DB;

class ChatService
{
    /**
     * Get project chat messages
     */
    public function getProjectMessages(int $projectId, int $offset, int $limit): array
    {
        $messages = ChatRoom::where('project_id', $projectId)
            ->with([
                'sender:customer_id,full_name,email,avatar',
                'content.resources'
            ])
            ->orderBy('message_id', 'desc')
            ->offset($offset)
            ->limit($limit)
            ->get();

        return $messages->map(function ($message) {
            return $this->formatRoomMessage($message);
        })->reverse()->values()->toArray();
    }

    /**
     * Get private chat messages between two users
     */
    public function getPrivateMessages(int $userId1, int $userId2, int $projectId, int $offset, int $limit): array
    {
        // Xóa điều kiện where project_id
        $messages = ChatPrivate::where(function ($query) use ($userId1, $userId2) {
                $query->where('sender_id', $userId1)->where('receiver_id', $userId2);
            })
            ->orWhere(function ($query) use ($userId1, $userId2) {
                $query->where('sender_id', $userId2)->where('receiver_id', $userId1);
            })
            ->with([
                'sender:customer_id,full_name,email,avatar',
                'receiver:customer_id,full_name,email,avatar',
                'content.resources'
            ])
            ->orderBy('message_id', 'desc')
            ->offset($offset)
            ->limit($limit)
            ->get();

        return $messages->map(function ($message) {
            return $this->formatPrivateMessage($message);
        })->reverse()->values()->toArray();
    }

    /**
     * Send project chat message
     */
    public function sendProjectMessage(int $projectId, int $senderId, string $message, ?int $contentId): array
    {
        return DB::transaction(function () use ($projectId, $senderId, $message, $contentId) {
            // Create content container for message resources
            $chatMessage = ChatRoom::create([
                'message' => $message,
                'project_id' => $projectId,
                'sender_id' => $senderId,
                'content_id' => $contentId ?? null,
            ]);

            return $this->formatRoomMessage($chatMessage->load(['sender', 'content.resources']));
        });
    }

    /**
     * Send private message
     */
    public function sendPrivateMessage(int $projectId, int $senderId, int $receiverId, ?string $message, ?int $contentId): array
    {
        return DB::transaction(function () use ($projectId, $senderId, $receiverId, $message, $contentId) {
            // Create content container for message resources
            $chatMessage = ChatPrivate::create([
                'message' => $message,
                'project_id' => $projectId,  
                'sender_id' => $senderId,
                'receiver_id' => $receiverId,
                'content_id' => $contentId ?? null,
            ]);

            return $this->formatPrivateMessage($chatMessage->load(['sender', 'receiver', 'content.resources']));
        });
    }

    /**
     * Mark private message as read
     */
    public function markAsRead(int $customerId, int $messageId): bool
    {
        $messages = ChatPrivate::where('message_id', '<=', $messageId)
            ->where('receiver_id', $customerId)
            ->update(['is_read' => true]);
        
        return $messages > 0;
    }

    /**
     * Pin message
     */
    public function pinProjectMessage(int $messageId): bool
    {
        $message = ChatRoom::where('message_id', $messageId)
            ->update(['is_important' => true]);
        
        return $message > 0;
    }

    /**
     * Unpin message
     */
    public function unpinProjectMessage(int $messageId): bool
    {
        $message = ChatRoom::where('message_id', $messageId)
            ->update(['is_important' => false]);
        
        return $message > 0;
    }

    /**
     * Pin private message
     */
    public function pinPrivateMessage(int $messageId): bool
    {
        $message = ChatPrivate::where('message_id', $messageId)
            ->update(['is_important' => true]);
        
        return $message > 0;
    }

    /**
     * Unpin private message
     */
    public function unpinPrivateMessage(int $messageId): bool
    {
        $message = ChatPrivate::where('message_id', $messageId)
            ->update(['is_important' => false]);
        
        return $message > 0;
    }

    /**
     * Get pinned message from project chat
     */
    public function getPinMessageProject(int $projectId, int $customerId): array
    {
        $messages = ChatRoom::where('project_id', $projectId)
            ->where('is_important', true)
            ->with([
                'sender:customer_id,full_name,email,avatar',
                'content.resources'
            ])
            ->orderBy('message_id', 'desc')
            ->get();

        return $messages->map(function ($message) {
            return $this->formatRoomMessage($message);
        })->toArray();
    }

    /**
     * Get pinned message from private chat
     */
    public function getPinMessagePrivate(int $projectId, int $customerId, int $otherUserId): array
    {
        $messages = ChatPrivate::where('project_id', $projectId)
            ->where('is_important', true)
            ->where(function ($query) use ($customerId, $otherUserId) {
                $query->where('sender_id', $customerId)->where('receiver_id', $otherUserId)
                    ->orWhere('sender_id', $otherUserId)->where('receiver_id', $customerId);
            })
            ->with([
                'sender:customer_id,full_name,email,avatar',
                'receiver:customer_id,full_name,email,avatar',
                'content.resources'
            ])
            ->orderBy('message_id', 'desc')
            ->get();

        return $messages->map(function ($message) {
            return $this->formatPrivateMessage($message);
        })->toArray();
    }

    /**
     * Search messages from project chat
     */
    public function searchMessages(int $projectId, string $query): array
    {
        $messages = ChatRoom::where('project_id', $projectId)
            ->where('message', 'like', "%{$query}%")
            ->with([
                'sender:customer_id,full_name,email,avatar',
                'content.resources'
            ])
            ->orderBy('message_id', 'desc')
            ->get();

        return $messages->map(function ($message) {
            return $this->formatRoomMessage($message);
        })->toArray();
    }

    /**
     * Search messages from private chat
     */
    public function searchPrivateMessages(int $projectId, string $query, int $customerId, int $otherUserId): array
    {
        $messages = ChatPrivate::where('project_id', $projectId)
            ->whereRaw("message COLLATE utf8mb4_bin LIKE ?", ["%{$query}%"])
            ->where(function ($query) use ($customerId, $otherUserId) {
                $query->where('sender_id', $customerId)->where('receiver_id', $otherUserId)
                    ->orWhere('sender_id', $otherUserId)->where('receiver_id', $customerId);
            })
            ->with([
                'sender:customer_id,full_name,email,avatar',
                'receiver:customer_id,full_name,email,avatar',
                'content.resources'
            ])
            ->orderBy('message_id', 'desc')
            ->get();

        return $messages->map(function ($message) {
            return $this->formatPrivateMessage($message);
        })->toArray();
    }

    /**
     * Format room message
     */
    private function formatRoomMessage($message): array
    {
        return [
            'message_id' => $message->message_id,
            'message' => $message->message,
            'project_id' => $message->project_id,
            'is_important' => $message->is_important,
            'created_at' => $message->created_at,
            'sender_id' => $message->sender_id,
            'sender' => $message->sender ? [
                'customer_id' => $message->sender->customer_id,
                'full_name' => $message->sender->full_name,
                'email' => $message->sender->email,
                'avatar' => $message->sender->avatar,
            ] : null,
            'resources' => $message->content && $message->content->resources ? 
                $message->content->resources->map(function ($resource) {
                    return [
                        'resource_id' => $resource->resource_id,
                        'file_name' => $resource->file_name,
                        'path' => $resource->path,
                        'type' => $resource->type,
                        'size' => $resource->size,
                    ];
                })->toArray() : [],
        ];
    }

    /**
     * Format private message
     */
    private function formatPrivateMessage($message): array
    {
        return [
            'message_id' => $message->message_id,
            'message' => $message->message,
            'is_read' => $message->is_read,
            'is_important' => $message->is_important,
            'created_at' => $message->created_at,
            'sender' => $message->sender ? [
                'customer_id' => $message->sender->customer_id,
                'full_name' => $message->sender->full_name,
                'email' => $message->sender->email,
                'avatar' => $message->sender->avatar,
            ] : null,
            'receiver' => $message->receiver ? [
                'customer_id' => $message->receiver->customer_id,
                'full_name' => $message->receiver->full_name,
                'email' => $message->receiver->email,
                'avatar' => $message->receiver->avatar,
            ] : null,
            'resources' => $message->content && $message->content->resources ? 
                $message->content->resources->map(function ($resource) {
                    return [
                        'resource_id' => $resource->resource_id,
                        'file_name' => $resource->file_name,
                        'path' => $resource->path,
                        'type' => $resource->type,
                        'size' => $resource->size,
                    ];
                })->toArray() : [],
        ];
    }
}

