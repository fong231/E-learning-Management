<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\ProfileApiController;
use App\Http\Controllers\Api\ProjectApiController;
use App\Http\Controllers\Api\TaskApiController;
use App\Http\Controllers\Api\ChatApiController;
use App\Http\Controllers\Api\ResourceApiController;
use App\Http\Controllers\Api\MailApiController;
use App\Http\Controllers\ProjectController;

// Public API routes
Route::post('/login', [AuthApiController::class, 'login']);
Route::post('/register', [AuthApiController::class, 'register']);
Route::get('/jwt-token', [AuthApiController::class, 'getJwtToken']);

Route::get('/verify-email', [AuthApiController::class, 'verifyEmail']);
Route::post('/reset-password', [AuthApiController::class, 'resetPassword']);

// Mail
Route::post('/send-verification-email', [MailApiController::class, 'sendVerificationEmail']);
Route::post('/send-reset-password-email', [MailApiController::class, 'sendResetPasswordEmail']);

// Protected API routes
Route::middleware(['auth:api'])->group(function () {
    // Auth
    Route::post('/logout', [AuthApiController::class, 'logout']);
    Route::get('/me', [AuthApiController::class, 'me']);
    Route::get('/customers/{customerId}', [AuthApiController::class, 'detail']);
    Route::post('/customers/{customerId}/verification-token', [AuthApiController::class, 'saveVerificationToken']);
    Route::post('/reset-token', [AuthApiController::class, 'saveResetToken']);

    // Profile
    Route::post('/profile/update', [ProfileApiController::class, 'update']);
    Route::post('/profile/password', [ProfileApiController::class, 'updatePassword']);

    // Projects
    Route::get('/projects', [ProjectApiController::class, 'index']);
    Route::get('/projects/{projectId}', [ProjectApiController::class, 'detail']);
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::post('/projects/{project}', [ProjectController::class, 'update']);
    Route::delete('/projects/{project}', [ProjectController::class, 'destroy']);

    // Tasks
    Route::get('/projects/{projectId}/tasks', [TaskApiController::class, 'index']);
    Route::get('/projects/{projectId}/tasks/kanban', [TaskApiController::class, 'kanban']);
    Route::get('/projects/{projectId}/tasks/{taskId}', [TaskApiController::class, 'show']);
    Route::post('/projects/{projectId}/tasks', [TaskApiController::class, 'store']);
    Route::post('/projects/{projectId}/tasks/{taskId}', [TaskApiController::class, 'update']);
    Route::delete('/projects/{projectId}/tasks/{taskId}', [TaskApiController::class, 'destroy']);

    // Chat
    Route::get('/projects/{projectId}/chat', [ChatApiController::class, 'latestProjectMessage']);
    Route::get('/projects/{projectId}/chat-private/{otherUserId}', [ChatApiController::class, 'latestPrivateMessage']);
    Route::get('/projects/{projectId}/chat/messages', [ChatApiController::class, 'projectMessages']); // query: offset, limit
    Route::get('/projects/{projectId}/chat-private/{otherUserId}/messages', [ChatApiController::class, 'privateMessages']); // query: offset, limit
    Route::post('/projects/{projectId}/chat', [ChatApiController::class, 'sendProjectMessage']);
    Route::post('/projects/{projectId}/chat-private/{otherUserId}', [ChatApiController::class, 'sendPrivateMessage']);
    Route::post('/mark-as-read/{messageId}', [ChatApiController::class, 'markAsRead']);
    Route::post('/message/{messageId}/pin/{type}', [ChatApiController::class, 'pinMessage']);
    Route::post('/message/{messageId}/unpin/{type}', [ChatApiController::class, 'unpinMessage']);
    Route::get('/projects/{projectId}/chat/pin', [ChatApiController::class, 'getPinMessageProject']);
    Route::get('/projects/{projectId}/chat-private/{otherUserId}/pin', [ChatApiController::class, 'getPinMessagePrivate']);
    Route::get('/projects/{projectId}/chat-search', [ChatApiController::class, 'searchMessages']); // query: query, other_user_id

    // Resources
    Route::get('/projects/{projectId}/resources', [ResourceApiController::class, 'projectResources']);
    Route::get('/projects/{projectId}/tasks/{taskId}/resources', [ResourceApiController::class, 'taskResources']);
    Route::get('/contents/{contentId}/resources', [ResourceApiController::class, 'contentResources']);
    Route::get('/resources/{resourceId}/image', [ResourceApiController::class, 'resourceImage']);
    Route::get('/resources/{resourceId}/download/{download}', [ResourceApiController::class, 'getResourceById']);
    Route::post('/resources/upload', [ResourceApiController::class, 'upload']); // query: content_type
    Route::delete('/resources/{resourceId}', [ResourceApiController::class, 'destroy']);

    // Members
    Route::get('/projects/{projectId}/members', [ProjectApiController::class, 'projectMembers']);
    Route::post('/projects/{projectId}/members', [ProjectApiController::class, 'addProjectMember']);
    Route::delete('/projects/{projectId}/members/{memberId}', [ProjectApiController::class, 'removeProjectMember']);
    Route::put('/projects/{projectId}/members/{memberId}/role/{role}', [ProjectApiController::class, 'updateMemberRole']);
});
