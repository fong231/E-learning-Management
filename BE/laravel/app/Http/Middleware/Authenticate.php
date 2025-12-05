<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class Authenticate
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$guards): Response
    {
        if ($request->attributes->get('api_key_authenticated')) {
            return $next($request);
        }

        // If no guards specified, use 'api' as default for this app
        if (empty($guards)) {
            $guards = ['api'];
        }

        foreach ($guards as $guard) {
            if (Auth::guard($guard)->check()) {
                return $next($request);
            }
        }

        // Not authenticated - redirect to login
        if ($request->expectsJson()) {
            abort(401, 'Unauthenticated');
        }

        return redirect()->route('login');
    }
}
