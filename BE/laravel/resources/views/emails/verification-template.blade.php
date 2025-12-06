<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Verify Your Email Address</title>
    <style>
        /* CSS Reset & Base Styles */
        body { margin: 0; padding: 0; width: 100% !important; height: 100% !important; background-color: #f4f6fa; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; line-height: 1.6; color: #333333; }
        table { border-spacing: 0; border-collapse: collapse; }
        img { border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }
        
        /* Container */
        .email-container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-top: 40px; margin-bottom: 40px; }
        
        /* Header */
        .email-header { background-color: #4F46E5; padding: 30px; text-align: center; }
        .email-header h1 { color: #ffffff; margin: 0; font-size: 24px; font-weight: 600; }
        
        /* Body */
        .email-body { padding: 40px 30px; }
        .greeting { font-size: 18px; font-weight: bold; margin-bottom: 20px; color: #111827; }
        .text-content { margin-bottom: 25px; color: #4B5563; font-size: 15px; }
        
        /* Button */
        .button-container { text-align: center; margin: 35px 0; }
        .cta-button { display: inline-block; padding: 14px 30px; background-color: #4F46E5; color: #ffffff !important; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 16px; box-shadow: 0 2px 4px rgba(79, 70, 229, 0.3); transition: background-color 0.3s; }
        .cta-button:hover { background-color: #4338ca; }
        
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
                        <h1>ProjectFlow</h1> 
                    </div>

                    <!-- Body -->
                    <div class="email-body">
                        <p class="greeting">Hello {{ $customer_name ?? 'there' }},</p>
                        
                        <p class="text-content">
                            Thanks for signing up with <strong>ProjectFlow</strong>! 
                            To get started and secure your account, please verify your email address by clicking the button below.
                        </p>

                        <div class="button-container">
                            <a href="{{ $url }}" class="cta-button" target="_blank">Verify Email Address</a>
                        </div>

                        <p class="text-content">
                            If you did not create an account, no further action is required. Unverified accounts may be automatically removed after a certain period.
                        </p>
                        
                        <p class="text-content" style="margin-top: 30px;">
                            Best regards,<br>
                            The ProjectFlow Team
                        </p>

                        <!-- Fallback Link -->
                        <div class="fallback-link">
                            <p>If you're having trouble clicking the "Verify Email Address" button, copy and paste the URL below into your web browser:</p>
                            <a href="{{ $url }}" style="color: #4F46E5;">{{ $url }}</a>
                        </div>
                    </div>

                    <!-- Footer -->
                    <div class="email-footer">
                        &copy; {{ date('Y') }} ProjectFlow Inc. All rights reserved.<br>
                        This is an automated email, please do not reply.
                    </div>
                </div>
            </td>
        </tr>
    </table>
</body>
</html>