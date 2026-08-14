<?php

namespace App\Http\Requests\Cable;

use App\Enums\CableProvider;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class VerifySmartcardRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'cable_provider' => ['required', new Enum(CableProvider::class)],
            'smartcard_number' => ['required', 'string', 'min:8', 'max:20'],
        ];
    }
}