<?php

namespace App\Enums;

enum CommissionType: string
{
    case Percentage = 'percentage';
    case Flat = 'flat';
}