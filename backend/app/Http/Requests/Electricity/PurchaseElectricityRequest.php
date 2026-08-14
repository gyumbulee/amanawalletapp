<?php

namespace App\Http\Requests\Electricity;

use App\Enums\ElectricityDisco;
use App\Enums\MeterType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class PurchaseElectricityRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'disco' => ['required', new Enum(ElectricityDisco::class)],
            'meter_number' => ['required', 'string', 'min:10', 'max:20'],
            'meter_type' => ['required', new Enum(MeterType::class)],
            'amount' => ['required', 'numeric', 'min:500', 'max:100000'],
            'phone' => ['required', 'string', 'digits_between:10,15'],
        ];
    }
}