<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    protected $fillable = [
        'title', 'image_path', 'link_type', 'link_value',
        'sort_order', 'is_active', 'starts_at', 'ends_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
        ];
    }

    public function imageUrl(): string
    {
        // Not Storage::disk('public')->url() - that points at the raw
        // /storage symlink, which is served as a static file and never
        // gets Laravel's CORS headers attached (breaks Flutter Web
        // specifically). This route goes through BannerImageController
        // instead, which explicitly sets Access-Control-Allow-Origin.
        return url('/api/v1/banner-images/' . basename($this->image_path));
    }

    public function scopeCurrentlyActive(Builder $query): Builder
    {
        $now = now();

        return $query->where('is_active', true)
            ->where(fn ($q) => $q->whereNull('starts_at')->orWhere('starts_at', '<=', $now))
            ->where(fn ($q) => $q->whereNull('ends_at')->orWhere('ends_at', '>=', $now));
    }
}
