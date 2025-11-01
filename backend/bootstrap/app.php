<?php
/** @phpstan-ignore-next-line */
/** @phpstan-ignore-next-line */

/**
 * Bootstrap Application
 * 
 * This file bootstraps the Laravel application and returns the application instance.
 */

/** @phpstan-ignore-next-line */
use Illuminate\Foundation\Application;
/** @phpstan-ignore-next-line */
use Illuminate\Foundation\Configuration\Exceptions;
/** @phpstan-ignore-next-line */
use Illuminate\Foundation\Configuration\Middleware;

/** @phpstan-ignore-next-line */
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);
        
        // Rate limiting - Production security (configured in routes/api.php)
        // Protects against brute-force attacks:
        // - Login: 5 requests/minute (throttle:5,1)
        // - Register: 3 requests/minute (throttle:3,1)
        // - General API: 60 requests/minute (default throttle)
        
        // CSRF protection is handled by Sanctum for API routes
        // For stateful frontend requests, CSRF tokens are automatically verified
        $middleware->validateCsrfTokens(except: [
            // Webhook endpoints from external services
            'api/upload/callback',
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();

