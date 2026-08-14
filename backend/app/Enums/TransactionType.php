<?php

namespace App\Enums;

enum TransactionType: string
{
    case WalletFunding = 'wallet_funding';
    case Airtime = 'airtime';
    case Data = 'data';
    case Electricity = 'electricity';
    case Cable = 'cable';
    case Education = 'education';
    case ReferralBonus = 'referral_bonus';
}