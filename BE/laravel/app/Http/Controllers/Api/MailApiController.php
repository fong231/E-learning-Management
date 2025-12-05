<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MailService;
use App\Helpers\AuthHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class MailApiController extends Controller
{
    protected $mailService;

    public function __construct(MailService $mailService)
    {
        $this->mailService = $mailService;
    }

    /**
     * Send verification email
     */
    public function sendVerificationEmail(Request $request)
    {
        $customerId = AuthHelper::getCustomerId($request) ?? $request->customer_id;
        $response = Http::withHeaders([
            'x-api-key' => env('API_KEY'),
        ])->get('http://localhost:80/api/customers/' . $customerId);

        if ($response->status() !== 200) {
            return response()->json([
                'success' => false,
                'message' => 'Customer not found',
            ], 404);
        }

        $customer = ($response->json())['data'];
        $token = bin2hex(random_bytes(32));
        $response = Http::withHeaders([
            'x-api-key' => env('API_KEY'),
        ])->post('http://localhost:80/api/customers/' . $customerId . '/verification-token', [
            'token' => $token,
            'expires_at' => now()->addMinutes(30)->toDateTimeString(),
        ]);

        $info = [
            'type' => 'verification',
            'token' => $token,
            'full_name' => $customer['full_name'],
            'customer_id' => $customerId,
        ];

        $sent = $this->mailService->sendVerificationEmail($customer['email'], $info);

        if (!$sent) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to send email',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Email sent successfully',
        ]);
    }

    /**
     * Send reset password email
     */
    public function sendResetPasswordEmail(Request $request)
    {
        $customerEmail = $request->email;
        $token = bin2hex(random_bytes(32));
        
        $response = Http::withHeaders([
            'x-api-key' => env('API_KEY'),
        ])->post('http://localhost:80/api/reset-token', [
            'email' => $customerEmail,
            'token' => $token,
            'expires_at' => now()->addMinutes(30)->toDateTimeString(),
        ]);

        if ($response->status() !== 200) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save token',
            ], 500);
        }

        $info = [
            'type' => 'reset-password',
            'token' => $token,
        ];

        $sent = $this->mailService->sendResetPasswordEmail($customerEmail, $info);

        if (!$sent) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to send email',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Email sent successfully',
        ]);
    }
}

