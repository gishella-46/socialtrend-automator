<?php
/** @phpstan-ignore-next-line */
/** @phpstan-ignore-next-line */

/**
 * Web Routes
 * 
 * Here is where you can register web routes for your application.
 */

/** @phpstan-ignore-next-line */
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    /** @phpstan-ignore-next-line */
    return response()->json(['message' => 'SocialTrend Automator API']);
});

