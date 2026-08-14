<?php

namespace App\Http\Requests\Education;

use App\Enums\EducationType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class PurchaseEducationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'education_type' => ['required', new Enum(EducationType::class)],
            'variation_code' => ['required', 'string'],
            'phone' => ['required', 'string', 'digits_between:10,15'],
            'profile_id' => ['required_if:education_type,jamb', 'nullable', 'string'],
            'pin' => ['required', 'string', 'digits:4'],
        ];
    }
}