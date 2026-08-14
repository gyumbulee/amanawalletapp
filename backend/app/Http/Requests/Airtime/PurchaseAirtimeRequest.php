<?php

namespace App\Http\Requests\Airtime;

use App\Enums\AirtimeNetwork;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class PurchaseAirtimeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'network' => ['required', new Enum(AirtimeNetwork::class)],
            'phone' => ['required', 'string', 'digits_between:10,15'],
            'amount' => ['required', 'numeric', 'min:50', 'max:50000'],
            'pin' => ['required', 'string', 'digits:4'],
        ];
    }
}