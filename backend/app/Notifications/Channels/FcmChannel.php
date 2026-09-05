<?php

namespace App\Notifications\Channels;

use App\Services\FcmService;
use Illuminate\Notifications\Notification;

/**
 * Returned from a Notification's via() alongside 'mail'/'database':
 *
 *   public function via(object $notifiable): array
 *   {
 *       return ['mail', 'database', FcmChannel::class];
 *   }
 *
 * Laravel resolves a channel returned this way straight out of the
 * container, so no separate registration/service-provider binding is
 * needed - just implement toFcm() on the notification class.
 */
class FcmChannel
{
    public function __construct(private FcmService $fcm) {}

    public function send(object $notifiable, Notification $notification): void
    {
        if (! method_exists($notification, 'toFcm')) {
            return;
        }

        if (! method_exists($notifiable, 'getKey')) {
            return;
        }

        ['title' => $title, 'body' => $body, 'data' => $data] = $notification->toFcm($notifiable);

        $this->fcm->sendToUser($notifiable->getKey(), $title, $body, $data);
    }
}
