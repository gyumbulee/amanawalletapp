<?php

namespace App\Http\Middleware;

use App\Models\Setting;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckMaintenanceMode
{
    public function handle(Request $request, Closure $next): Response
    {
        if ((bool) Setting::get('maintenance_mode', false)) {
            return response()->json([
                'message' => 'Amana Wallet is currently under maintenance. Please try again shortly.',
            ], 503);
        }

        return $next($request);
    }
}