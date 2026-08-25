<?php

namespace App\Enums;

enum WebhookStatus: string
{
    case Pending = 'pending';
    case Processed = 'processed';
    case Failed = 'failed';
}
