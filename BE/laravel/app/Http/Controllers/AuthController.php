<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cookie;

class AuthController extends Controller
{
    // --- WEB UI METHODS ---
    public function show()
    {
        return view('auth.show');
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

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:customers,email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = Customer::create([
            'full_name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        $token = Auth::guard('api')->login($user);

        if ($request->expectsJson()) {
            return $this->respondWithToken($token);
        }

        $ttl = Auth::guard('api')->factory()->getTTL();
        $cookie = cookie('jwt_token', $token, $ttl);

        return redirect()->route('dashboard.show')->withCookie($cookie);
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login');
    }

    public function detail(int $customerId)
    {
        $customer = Customer::where('customer_id', $customerId)->first();
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

    public function saveVerificationToken(Request $request)
    {
        $validated = $request->validate([
            'token' => 'required|string',
            'expires_at' => 'required|date',
        ]);

        $customer = Auth::guard('api')->user();

        $customer->update([
            'verification_token' => $validated['token'],
            'verification_token_expires_at' => $validated['expires_at'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Token saved successfully',
        ]);
    }

    public function saveResetToken(Request $request)
    {
        $validated = $request->validate([
            'token' => 'required|string',
            'expires_at' => 'required|date',
        ]);

        $customer = Auth::guard('api')->user();

        $customer->update([
            'reset_token' => $validated['token'],
            'reset_token_expires_at' => $validated['expires_at'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Token saved successfully',
        ]);
    }
}