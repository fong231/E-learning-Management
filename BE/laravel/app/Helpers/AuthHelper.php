<?php

namespace App\Helpers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthHelper
{
    public static function getCustomerId(Request $request): ?int
    {

        // 1. API Key
        if ($request->attributes->get('api_key_authenticated')) {
            return $request->attributes->get('api_key_customer_id');
        }

        // 2. JWT (API Guard)
        if (Auth::guard('api')->check()) {
            return Auth::guard('api')->id();
        }
        return null;
    }

    public static function isApiKeyAuth(Request $request): bool
    {
        return $request->attributes->get('api_key_authenticated', false);
    }
}