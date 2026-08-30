<?php

namespace App\Models;

use App\Enums\DataPlanCategory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class DataPlan extends Model
{
    protected $fillable = [
        'network', 'variation_code', 'category', 'name',
        'cost_price', 'selling_price', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'category' => DataPlanCategory::class,
            'cost_price' => 'decimal:2',
            'selling_price' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function revenue(): float
    {
        return (float) $this->selling_price - (float) $this->cost_price;
    }

    public function scopeForNetwork(Builder $query, string $network): Builder
    {
        return $query->where('network', $network);
    }

    public function scopeForCategory(Builder $query, string $category): Builder
    {
        return $query->where('category', $category);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
