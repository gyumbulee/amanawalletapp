<?php

namespace App\Enums;

enum KycType: string
{
    case Bvn = 'bvn';
    case Nin = 'nin';
    case IdCard = 'id_card';
    case ProofOfAddress = 'proof_of_address';
}