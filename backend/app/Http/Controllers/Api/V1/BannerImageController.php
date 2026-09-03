<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class BannerImageController extends Controller
{
    /**
     * Serves banner images through Laravel instead of the raw /storage
     * symlink path. Files under /storage are served directly as static
     * files (by php artisan serve locally, or by nginx/Apache in
     * production) and never touch Laravel's HTTP kernel - which means
     * HandleCors middleware never runs for them, so no
     * Access-Control-Allow-Origin header is ever sent. That's invisible
     * on native mobile and when opening the URL directly in a browser
     * (plain navigation isn't subject to CORS), but Flutter Web's
     * CachedNetworkImage has to actually fetch() the bytes to cache
     * them, which IS subject to CORS - so the image silently fails to
     * load there specifically. Routing through here guarantees the
     * header is present regardless of platform or how the file happens
     * to be served underneath.
     */
    public function show(string $filename): BinaryFileResponse|Response
    {
        // basename() strips any directory traversal attempt (e.g. "../../.env").
        $safeFilename = basename($filename);
        $path = "banners/{$safeFilename}";

        if (! Storage::disk('public')->exists($path)) {
            return response('Not found', 404);
        }

        return response()
            ->file(Storage::disk('public')->path($path))
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Cache-Control', 'public, max-age=86400');
    }
}
