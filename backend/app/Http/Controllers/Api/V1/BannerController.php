<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;

class BannerController extends Controller
{
    public function index(): JsonResponse
    {
        $banners = Banner::query()
            ->currentlyActive()
            ->orderBy('sort_order')
            ->get();

        return response()->json(['banners' => BannerResource::collection($banners)]);
    }
}
