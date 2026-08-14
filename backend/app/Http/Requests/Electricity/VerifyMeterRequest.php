<?php

namespace App\Http\Requests\Electricity;

use App\Enums\ElectricityDisco;
use App\Enums\MeterType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class VerifyMeterRequest extends FormRequest
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
        ];
    }
}