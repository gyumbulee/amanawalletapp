<?php

namespace App\Enums;

enum CableProvider: string
{
    case Dstv = 'dstv';
    case Gotv = 'gotv';
    case Startimes = 'startimes';
    case Showmax = 'showmax';
}