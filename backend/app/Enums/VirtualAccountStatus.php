<?php

namespace App\Enums;

enum VirtualAccountStatus: string
{
    case Pending = 'pending';
    case Active = 'active';
    case Inactive = 'inactive';
    case Failed = 'failed';
}