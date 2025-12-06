<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AuthService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cookie;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AuthApiController extends Controller
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    public function register(Request $request)
    {
        try {
            $validated = $request->validate([
                'full_name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:customers,email',
                'password' => 'required|string|min:6|confirmed',
            ]);

            $customer = $this->authService->register($validated);

            $response = Http::withHeaders([
                'x-api-key' => env('API_KEY'),
            ])->post('http://localhost:80/api/send-verification-email', [
                'customer_id' => $customer->customer_id,
            ]);

            if ($response->status() !== 200) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to send verification email',
                ], 500);
            }

            $credentials = $request->only('email', 'password');
            if (! $token = Auth::guard('api')->attempt($credentials)) {
                if ($request->expectsJson()) {
                    return response()->json(['error' => 'Unauthorized', 'message' => 'Email or password is incorrect.'], 401);
                }
                return back()->withErrors(['email' => 'Email or password is incorrect.'])->onlyInput('email');
            }

            if ($request->expectsJson()) {
                return $this->respondWithToken($token);
            }

            $ttl = Auth::guard('api')->factory()->getTTL();
            $cookie = cookie('jwt_token', $token, $ttl);
            
            return redirect()->intended('/dashboard')->withCookie($cookie);
        } catch (\Exception $e) {
            Log::error($e->getMessage());
        }
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (! $token = Auth::guard('api')->attempt($credentials)) {
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Unauthorized', 'message' => 'Email or password is incorrect.'], 401);
            }
            return back()->withErrors(['email' => 'Email or password is incorrect.'])->onlyInput('email');
        }

        if ($request->expectsJson()) {
            return $this->respondWithToken($token);
        }

        $ttl = Auth::guard('api')->factory()->getTTL();
        $cookie = cookie('jwt_token', $token, $ttl);
        
        return redirect()->intended('/dashboard')->withCookie($cookie);
    }

    public function logout(Request $request)
    {
        try {
            Auth::guard('api')->logout();
        } catch (\Exception $e) {
            
        }

        if ($request->expectsJson()) {
            return response()->json(['message' => 'Successfully logged out']);
        }

        $cookie = Cookie::forget('jwt_token');
        $request->session()->invalidate();
        
        return redirect()->route('login')->withCookie($cookie);
    }

    public function me()
    {
        $user = Auth::guard('api')->user();

        return response()->json([
            'success' => true,
            'data' => [
                'customer_id' => $user->customer_id,
                'full_name' => $user->full_name,
                'email' => $user->email,
                'avatar' => $user->avatar,
                'nickname' => $user->nickname,
            ]
        ]);
    }

    public function detail(int $customerId)
    {
        $customer = $this->authService->detail($customerId);

        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Customer not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $customer,
        ]);
    }

    public function getJwtToken(Request $request)
    {
        return response()->json([
            'token' => $request->cookie('jwt_token'),
        ]);
    }

    public function saveVerificationToken(Request $request, int $customerId)
    {
        $validated = $request->validate([
            'token' => 'required|string',
            'expires_at' => 'required|date',
        ]);

        $result = $this->authService->saveVerificationToken($customerId, $validated['token'], $validated['expires_at']);

        if (!$result) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save token',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Token saved successfully',
        ]);
    }

    public function verifyEmail(Request $request)
    {
        $token = $request->query("token");
        $customer_id = $request->query("customer_id");

        $result = $this->authService->verifyEmail($customer_id, $token);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'message' => $result['message'],
            ], 500);
        }

        return redirect()->intended('/verify-email-success');
    }

    public function saveResetToken(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
            'expires_at' => 'required|date',
        ]);

        $result = $this->authService->saveResetToken($validated['email'], $validated['token'], $validated['expires_at']);

        if (!$result) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save token',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Token saved successfully',
        ]);
    }

    public function resetPassword(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $result = $this->authService->resetPassword($validated['email'], $validated['token'], $validated['password']);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'message' => $result['message'],
            ], 500);
        }

        return redirect()->intended('/reset-password-success');
    }
}