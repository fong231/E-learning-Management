<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Project;
use App\Models\Customer;
use App\Models\ChatRoom;
use App\Models\ChatPrivate;
use App\Models\Content;

class ChatController extends Controller
{
    public function projectChat(Project $project)
    {
        // Check if user is member of project
        $isMember = $project->members()->where('member_id', Auth::id())->exists();
        
        if (!$isMember && $project->owner_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        $messages = ChatRoom::where('project_id', $project->project_id)
            ->with('sender', 'resources')
            ->orderBy('created_at', 'asc')
            ->get();

        $members = $project->members()->with('member')->get();

        return view('chat.project', compact('project', 'messages', 'members'));
    }

    public function storeProjectMessage(Request $request, Project $project)
    {
        // Check if user is member of project
        $isMember = $project->members()->where('member_id', Auth::id())->exists();
        
        if (!$isMember && $project->owner_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        $validated = $request->validate([
            'message' => 'required|string',
        ]);

        // Create content record
        $content = Content::create([
            'type' => 'chat_room',
        ]);

        $message = ChatRoom::create([
            'message' => $validated['message'],
            'project_id' => $project->project_id,
            'sender_id' => Auth::id(),
            'content_id' => $content->content_id,
        ]);

        return response()->json($message->load('sender'), 201);
    }

    public function privateChat(Customer $user)
    {
        $messages = ChatPrivate::where(function ($query) use ($user) {
            $query->where('sender_id', Auth::id())
                  ->where('receiver_id', $user->customer_id);
        })->orWhere(function ($query) use ($user) {
            $query->where('sender_id', $user->customer_id)
                  ->where('receiver_id', Auth::id());
        })->with('sender', 'resources')
          ->orderBy('created_at', 'asc')
          ->get();

        return view('chat.private', compact('user', 'messages'));
    }

    public function storePrivateMessage(Request $request, Customer $user)
    {
        $validated = $request->validate([
            'message' => 'required|string',
        ]);

        // Create content record
        $content = Content::create([
            'type' => 'chat_private',
        ]);

        $message = ChatPrivate::create([
            'message' => $validated['message'],
            'sender_id' => Auth::id(),
            'receiver_id' => $user->customer_id,
            'content_id' => $content->content_id,
        ]);

        return response()->json($message->load('sender'), 201);
    }
}
