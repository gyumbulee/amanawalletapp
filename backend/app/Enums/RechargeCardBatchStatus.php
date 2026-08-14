<?php

namespace App\Enums;

enum RechargeCardBatchStatus: string
{
    case Pending = 'pending';
    case Completed = 'completed';
    case Failed = 'failed';
}