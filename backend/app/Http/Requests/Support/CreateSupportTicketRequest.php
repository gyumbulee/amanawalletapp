<?php

namespace App\Http\Requests\Support;

use Illuminate\Foundation\Http\FormRequest;

class CreateSupportTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject' => ['required', 'string', 'max:150'],
            'message' => ['required', 'string', 'max:2000'],
            // Validated for existence only here - ownership (is this the
            // caller's own transaction?) is checked in SupportTicketService
            // so a mismatch returns a clear message rather than a generic
            // validation failure.
            'transaction_reference' => ['nullable', 'string', 'exists:transactions,reference'],
        ];
    }
}
