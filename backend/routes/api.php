<?php
/** @phpstan-ignore-next-line */
/** @phpstan-ignore-next-line */

/**
 * API Routes
 * 
 * Here is where you can register API routes for your application.
 */

/** @phpstan-ignore-next-line */
use App\Http\Controllers\AuthController;
/** @phpstan-ignore-next-line */
use App\Http\Controllers\ScheduleController;
/** @phpstan-ignore-next-line */
use App\Http\Controllers\TrendController;
/** @phpstan-ignore-next-line */
use App\Http\Controllers\UserController;
/** @phpstan-ignore-next-line */
use Illuminate\Http\Request;
/** @phpstan-ignore-next-line */
use Illuminate\Support\Facades\Route;

/**
 * @group Authentication
 * 
 * Public authentication endpoints
 * Rate limited: 5 requests/minute for login, 3 requests/minute for register
 */
Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:3,1');
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');

/**
 * @group User Management
 * 
 * Get current authenticated user information
 */
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [UserController::class, 'user']);
    
    /**
     * @group Trends
     * 
     * Fetch and manage trends data
     */
    Route::get('/trends', [TrendController::class, 'index']);
    
    /**
     * @group Scheduling
     * 
     * Schedule posts for social media platforms
     */
    Route::post('/schedule', [ScheduleController::class, 'store']);
});

/**
 * @group Webhooks
 * 
 * Webhook endpoints for external services
 */
Route::post('/upload/callback', [\App\Http\Controllers\UploadWebhookController::class, 'callback']);

/**
 * @group Metrics
 * 
 * Prometheus metrics endpoint for monitoring
 */
Route::get('/metrics', [\App\Http\Controllers\MetricsController::class, 'index']);

// Health check
Route::get('/health', function () {
    /** @phpstan-ignore-next-line */
    return response()->json([
        'status' => 'healthy',
        'service' => 'SocialTrend Automator API',
        'version' => '1.0.0'
    ]);
});

// API info
Route::get('/', function () {
    /** @phpstan-ignore-next-line */
    return response()->json([
        'message' => 'SocialTrend Automator API',
        'version' => '1.0.0',
        'endpoints' => [
            'register' => 'POST /api/register',
            'login' => 'POST /api/login',
            'user' => 'GET /api/user (auth required)',
            'trends' => 'GET /api/trends (auth required)',
            'schedule' => 'POST /api/schedule (auth required)',
            'health' => 'GET /api/health'
        ]
    ]);
});

