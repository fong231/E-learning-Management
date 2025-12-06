<?php

namespace App\Services;

use App\Mail\GenericEmail;
use Illuminate\Support\Facades\Mail;

class MailService
{
    
    public function sendVerificationEmail(string $email, array $info): bool
    {
        $subject = 'Verify Your Email Address';
        $info = [
            'type' => 'verification',
            'token' => $info['token'],
            'full_name' => $info['full_name'],
            'customer_id' => $info['customer_id'],
        ];

        return $this->sendEmail($email, $subject, $info);
    }

    public function sendResetPasswordEmail(string $email, array $info): bool
    {
        $subject = 'Reset Password Notification';
        $info = [
            'type' => 'reset-password',
            'token' => $info['token'],
            'email' => $email,
        ];

        return $this->sendEmail($email, $subject, $info);
    }
    
    private function sendEmail(string $email, string $subject, array $info): bool
    {
        try {
            Mail::to($email)->send(new GenericEmail($subject, $info));
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }
}