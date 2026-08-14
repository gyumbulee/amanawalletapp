<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;

class SetTransactionPinRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // Required only when the user already has a PIN set (changing it, not setting it the first time).
            'current_pin' => ['nullable', 'string', 'digits:4'],
            'pin' => ['required', 'string', 'digits:4', 'confirmed'],
        ];
    }
}