<?php

namespace App\Services;

use App\Models\Customer;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class AuthService
{
    public function register(array $data): Customer
    {
        return Customer::create([
            'full_name' => $data['full_name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);
    }

    public function detail(int $customerId): ?array
    {
        $customer = Customer::where('customer_id', $customerId)->first();

        if (!$customer) {
            return null;
        }

        return [
            'customer_id' => $customer->customer_id,
            'full_name' => $customer->full_name,
            'email' => $customer->email,
            'avatar' => $customer->avatar,
            'nickname' => $customer->nickname,
        ];
    }

    public function saveVerificationToken(int $customerId, string $token, string $expiresAt): bool
    {
        $customer = Customer::where('customer_id', $customerId)->first();
        
        if (!$customer) {
            return false;
        }

        $customer->update([
            'verification_token' => $token,
            'verification_token_expires_at' => $expiresAt,
        ]);

        return true;
    }

    public function verifyEmail(int $customerId, string $token)
    {
        $customer = Customer::where('customer_id', $customerId)
            ->where('verification_token', $token)
            ->first();
        
        if (!$customer) {
            return [
                'success' => false,
                'message' => 'Customer not found',
            ];
        }

        $expiresAt = Carbon::parse($customer->verification_token_expires_at);

        if ($expiresAt < Carbon::now()) {
            return [
                'success' => false,
                'message' => 'Token expired',
            ];
        }

        $customer->update([
            'email_verified_at' => now(),
            'verification_token' => null,
            'verification_token_expires_at' => null,
        ]);

        return [
            'success' => true,
            'message' => 'Email verified successfully',
        ];
    }

    public function saveResetToken(string $email, string $token, string $expiresAt): bool
    {
        $customer = Customer::where('email', $email)->first();
        
        if (!$customer) {
            return false;
        }

        $customer->update([
            'reset_token' => $token,
            'reset_token_expires_at' => $expiresAt,
        ]);

        return true;
    }

    public function resetPassword(string $email, string $token, string $password)
    {
        $customer = Customer::where('email', $email)
            ->where('reset_token', $token)
            ->first();
        
        if (!$customer) {
            return [
                'success' => false,
                'message' => 'Customer not found',
            ];
        }

        $expiresAt = Carbon::parse($customer->reset_token_expires_at);

        if ($expiresAt < Carbon::now()) {
            return [
                'success' => false,
                'message' => 'Token expired',
            ];
        }

        $customer->update([
            'password' => Hash::make($password),
            'reset_token' => null,
            'reset_token_expires_at' => null,
        ]);

        return [
            'success' => true,
            'message' => 'Password reset successfully',
        ];
    }
}