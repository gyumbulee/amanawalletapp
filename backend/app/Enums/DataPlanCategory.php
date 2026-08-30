<?php

namespace App\Enums;

enum DataPlanCategory: string
{
    case Gifting = 'gifting';
    case CorporateGifting = 'cgifting';
    case Sme = 'sme';
    case DataTransfer = 'data_transfer';
    case Other = 'other';

    public function label(): string
    {
        return match ($this) {
            self::Gifting => 'Gifting',
            self::CorporateGifting => 'Corporate Gifting',
            self::Sme => 'SME',
            self::DataTransfer => 'Data Transfer',
            self::Other => 'Other',
        };
    }

    /**
     * Derives a category from a provider's raw plan name, e.g.
     * "500 SME - 7-20days" -> Sme, "200CGIFTING - 14 days" -> CorporateGifting.
     *
     * Matches the FIRST category-like word after the leading size number
     * (not just any occurrence of "SME"/"GIFTING" in the string) - plans
     * like "1 GIFTING - 7days SME" mention both, but the real category is
     * whichever one is right after the size, so we anchor there.
     */
    public static function fromPlanName(string $name): self
    {
        if (! preg_match('/^[\d.]+\s*([A-Za-z]+)/', trim($name), $matches)) {
            return self::Other;
        }

        return match (strtoupper($matches[1])) {
            'GIFTING' => self::Gifting,
            'CGIFTING' => self::CorporateGifting,
            'SME' => self::Sme,
            'DATATRANSFER' => self::DataTransfer,
            default => self::Other,
        };
    }
}
