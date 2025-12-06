<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification History - OC System</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="bg-gray-50 min-h-screen">

    {{-- Header --}}
    <div class="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between sticky top-0 z-10 shadow-sm">
        <div class="flex items-center">
            <a href="{{ route('dashboard') }}" class="text-gray-500 hover:text-indigo-600 transition mr-4">
                <i data-lucide="arrow-left" class="w-5 h-5"></i>
            </a>
            <h1 class="text-xl font-bold text-gray-800">Notifications History</h1>
        </div>
        
        {{-- Nút Mark All Read ở trang lịch sử --}}
        <a href="{{ route('notifications.markAll') }}" class="text-sm text-indigo-600 font-medium hover:underline flex items-center">
            <i data-lucide="check-check" class="w-4 h-4 mr-1"></i> Mark all as read
        </a>
    </div>

    <main class="max-w-3xl mx-auto py-8 px-4">
        
        @if($allNotifications->count() > 0)
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                <div class="divide-y divide-gray-100">
                    @foreach($allNotifications as $notify)
                        <div class="p-4 hover:bg-gray-50 transition flex items-start space-x-4 {{ $notify->read_at ? 'opacity-75' : 'bg-blue-50/30' }}">
                            
                            {{-- Icon --}}
                            <div class="flex-shrink-0 mt-1">
                                <div class="w-10 h-10 rounded-full flex items-center justify-center {{ $notify->read_at ? 'bg-gray-100 text-gray-400' : 'bg-blue-100 text-blue-600' }}">
                                    <i data-lucide="{{ $notify->data['icon'] ?? 'bell' }}" class="w-5 h-5"></i>
                                </div>
                            </div>

                            {{-- Content --}}
                            <div class="flex-1 min-w-0">
                                <div class="flex justify-between items-start">
                                    <p class="text-sm font-semibold text-gray-900">
                                        {{ $notify->data['title'] ?? 'Notification' }}
                                        @if(!$notify->read_at)
                                            <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">New</span>
                                        @endif
                                    </p>
                                    <span class="text-xs text-gray-500 whitespace-nowrap ml-2">
                                        {{ $notify->created_at->format('M d, H:i') }}
                                    </span>
                                </div>
                                
                                <p class="text-sm text-gray-600 mt-1">{{ $notify->data['message'] ?? '' }}</p>
                                
                                @if(isset($notify->data['link']))
                                    <a href="{{ route('notifications.read', $notify->id) }}" class="inline-block mt-2 text-xs font-medium text-indigo-600 hover:text-indigo-800">
                                        View Details &rarr;
                                    </a>
                                @endif
                            </div>
                        </div>
                    @endforeach
                </div>
                
                {{-- Phân trang --}}
                <div class="p-4 border-t border-gray-100 bg-gray-50">
                    {{ $allNotifications->links() }}
                </div>
            </div>
        @else
            <div class="text-center py-12">
                <div class="w-16 h-16 bg-gray-100 text-gray-400 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i data-lucide="bell-off" class="w-8 h-8"></i>
                </div>
                <h3 class="text-lg font-medium text-gray-900">No notifications</h3>
                <p class="text-gray-500">You don't have any notification history yet.</p>
            </div>
        @endif

    </main>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>