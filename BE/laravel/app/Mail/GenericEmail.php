<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class GenericEmail extends Mailable
{
    use Queueable, SerializesModels;
    public array $info;

    /**
     * Create a new message instance.
     */
    public function __construct(string $subject, array $info)
    {
        $this->subject($subject);
        $this->info = $info;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: $this->subject,
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        if ($this->info['type'] === 'verification') {
            return new Content(
                view: 'emails.verification-template',
                with: [
                    'url' => env('APP_URL') . '/api/verify-email?customer_id=' . $this->info['customer_id'] . '&token=' . $this->info['token'],
                    'customer_name' => $this->info['full_name'],
                ],
            );
        } else if ($this->info['type'] === 'reset-password') {
            return new Content(
                view: 'emails.reset-password-template',
                with: [
                    'url' => env('APP_URL') . '/new-password-input?email=' . $this->info['email'] . '&token=' . $this->info['token'],
                ],
            );
        } else {
            return new Content(
                view: 'emails.generic-template',
            );
        }
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
