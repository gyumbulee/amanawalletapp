<?php

namespace App\Http\Requests\Data;

use App\Enums\AirtimeNetwork;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class PurchaseDataRequest extends FormRequest
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
            'variation_code' => ['required', 'string'],
            'pin' => ['required', 'string', 'digits:4'],
        ];
    }
}