<?php

namespace App\Enums;

enum WalletLedgerType: string
{
    case Credit = 'credit';
    case Debit = 'debit';
}