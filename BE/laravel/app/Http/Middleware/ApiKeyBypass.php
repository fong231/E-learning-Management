<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiKeyBypass
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $providedKey = $request->header('X-API-KEY');
        $customerId = $request->header('X-CUSTOMER-ID');
        $systemKey = env('API_KEY');

        if ($providedKey && $providedKey === $systemKey) {
            $request->attributes->set('api_key_authenticated', true);
            $request->attributes->set('api_key_customer_id', $customerId);
            return $next($request);
        }

        return $next($request);
    }
}