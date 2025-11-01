<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

/**
 * CSRF Protection Middleware
 * 
 * Provides CSRF token verification for API endpoints
 */
class VerifyCsrfToken extends Middleware
{
    /**
     * The URIs that should be excluded from CSRF verification.
     *
     * @var array<int, string>
     */
    protected $except = [
        // API endpoints that use token authentication (Sanctum) are exempt
        // but we can enable CSRF for additional security
    ];
}








