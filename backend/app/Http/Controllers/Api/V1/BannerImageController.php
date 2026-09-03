<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class BannerImageController extends Controller
{
    public function show(string $filename): BinaryFileResponse|Response
    {
        // basename() strips any directory traversal attempt.
        $safeFilename = basename($filename);
        $path = "banners/{$safeFilename}";

        if (! Storage::disk('public')->exists($path)) {
            return response('Not found', 404);
        }

        return response()->file(
            Storage::disk('public')->path($path),
            [
                'Access-Control-Allow-Origin' => '*',
                'Cache-Control' => 'public, max-age=86400',
            ],
        );
    }
}