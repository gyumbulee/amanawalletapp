<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\Transaction;

class TransactionPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('transactions.view'); }
    public function view(Admin $admin, Transaction $transaction): bool { return $admin->can('transactions.view'); }
}
