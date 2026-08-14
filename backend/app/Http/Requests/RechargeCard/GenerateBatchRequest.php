<?php

namespace App\Http\Requests\RechargeCard;

use App\Enums\AirtimeNetwork;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class GenerateBatchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'network' => ['required', new Enum(AirtimeNetwork::class)],
            'denomination' => ['required', 'numeric', 'min:50', 'max:50000'],
            'quantity' => ['required', 'integer', 'min:1', 'max:1000'],
        ];
    }
    protected function prepareForValidation(): void
{
    \Log::info('GenerateBatchRequest', [
        'content_type' => $this->header('Content-Type'),
        'raw' => $this->getContent(),
        'all' => $this->all(),
        'json' => $this->json()->all(),
        'input' => $this->input(),
    ]);
}
}