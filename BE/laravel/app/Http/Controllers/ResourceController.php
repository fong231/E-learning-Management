<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Models\Project;
use App\Models\Resource;
use App\Models\Content;

class ResourceController extends Controller
{
    public function index(Project $project)
    {
        // Check if user is member of project
        $isMember = $project->members()->where('member_id', Auth::id())->exists();
        
        if (!$isMember && $project->owner_id !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        // Get all resources for this project
        $resources = Resource::whereIn('content_id', function ($query) use ($project) {
            $query->select('content_id')
                  ->from('contents')
                  ->whereIn('type', ['task', 'chat_room', 'chat_private']);
        })->with('uploadedBy')
          ->orderBy('created_at', 'desc')
          ->get();

        return view('resources.index', compact('project', 'resources'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'file' => 'required|file|max:10240', // 10MB max
            'content_id' => 'required|exists:contents,content_id',
        ]);

        $file = $validated['file'];
        $path = $file->store('uploads', 'public');

        // Create content record if not exists
        $content = Content::find($validated['content_id']);

        $resource = Resource::create([
            'path' => $path,
            'type' => in_array($file->getMimeType(), ['image/jpeg', 'image/png', 'image/gif', 'image/webp']) ? 'image' : 'file',
            'size' => $file->getSize(),
            'file_name' => $file->getClientOriginalName(),
            'uploaded_by' => Auth::id(),
            'content_id' => $validated['content_id'],
        ]);

        return response()->json($resource, 201);
    }

    public function download(Resource $resource)
    {
        // Check authorization
        $content = $resource->content;
        
        if ($content->type === 'chat_room') {
            $project = \App\Models\ChatRoom::where('content_id', $content->content_id)->first()?->project;
            if (!$project) abort(404);
            
            $isMember = $project->members()->where('member_id', Auth::id())->exists();
            if (!$isMember && $project->owner_id !== Auth::id()) {
                abort(403, 'Unauthorized');
            }
        }

        return Storage::disk('public')->download($resource->path, $resource->file_name);
    }

    public function destroy(Resource $resource)
    {
        // Check authorization
        if ($resource->uploaded_by !== Auth::id()) {
            abort(403, 'Unauthorized');
        }

        Storage::disk('public')->delete($resource->path);
        $resource->delete();

        return response()->json(['message' => 'Resource deleted successfully']);
    }
}
