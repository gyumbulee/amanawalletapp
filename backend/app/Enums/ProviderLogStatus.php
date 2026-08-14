<?php

namespace App\Enums;

enum ProviderLogStatus: string
{
    case Success = 'success';
    case Failed = 'failed';
    case Timeout = 'timeout';
}