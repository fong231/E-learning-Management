<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Reset Password Notification</title>
    <style>
        /* CSS Reset & Base Styles */
        body { margin: 0; padding: 0; width: 100% !important; height: 100% !important; background-color: #f4f6fa; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; line-height: 1.6; color: #333333; }
        
        /* Container */
        .email-container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-top: 40px; margin-bottom: 40px; }
        
        /* Header */
        .email-header { background-color: #EF4444; padding: 30px; text-align: center; }
        .email-header h1 { color: #ffffff; margin: 0; font-size: 24px; font-weight: 600; }
        
        /* Body */
        .email-body { padding: 40px 30px; }
        .greeting { font-size: 18px; font-weight: bold; margin-bottom: 20px; color: #111827; }
        .text-content { margin-bottom: 25px; color: #4B5563; font-size: 15px; }
        .warning-box { background-color: #FFF5F5; border-left: 4px solid #EF4444; padding: 15px; margin-bottom: 25px; color: #991B1B; font-size: 14px; }
        
        /* Button */
        .button-container { text-align: center; margin: 35px 0; }
        .cta-button { display: inline-block; padding: 14px 30px; background-color: #EF4444; color: #ffffff !important; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 16px; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.3); }
        
        /* Footer */
        .email-footer { background-color: #f9fafb; padding: 20px; text-align: center; font-size: 12px; color: #9CA3AF; border-top: 1px solid #e5e7eb; }
        .fallback-link { font-size: 12px; color: #6B7280; margin-top: 20px; word-break: break-all; }
    </style>
</head>
<body>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td align="center" style="padding: 20px;">
                <div class="email-container">
                    <!-- Header -->
                    <div class="email-header">
                        <h1>Reset Password Request</h1>
                    </div>

                    <!-- Body -->
                    <div class="email-body">
                        <p class="greeting">Hello,</p>
                        
                        <p class="text-content">
                            You are receiving this email because we received a password reset request for your account.
                        </p>

                        <div class="button-container">
                            <a href="{{ $url }}" class="cta-button" target="_blank">Reset Password</a>
                        </div>

                        <div class="warning-box">
                            <strong>Note:</strong> This password reset link will expire in {{ config('auth.passwords.users.expire') }} minutes.
                        </div>

                        <p class="text-content">
                            If you did not request a password reset, no further action is required. Your password remains safe.
                        </p>
                        
                        <p class="text-content" style="margin-top: 30px;">
                            Regards,<br>
                            ProjectFlow Security Team
                        </p>

                        <!-- Fallback Link -->
                        <div class="fallback-link">
                            <p>If you're having trouble clicking the "Reset Password" button, copy and paste the URL below into your web browser:</p>
                            <a href="{{ $url }}" style="color: #EF4444;">{{ $url }}</a>
                        </div>
                    </div>

                    <!-- Footer -->
                    <div class="email-footer">
                        &copy; {{ date('Y') }} ProjectFlow Inc. All rights reserved.<br>
                        If you need assistance, please contact support@projectflow.com
                    </div>
                </div>
            </td>
        </tr>
    </table>
</body>
</html>