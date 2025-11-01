<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Http\Controllers;

use Illuminate\Http\Request;

/**
 * User Controller
 * 
 * Handles user-related endpoints
 * 
 * @group User Management
 */
class UserController extends Controller
{
    /**
     * Get authenticated user
     * 
     * Returns the currently authenticated user information.
     * 
     * @response 200 {
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "created_at": "2024-01-01T00:00:00.000000Z"
     *   }
     * }
     * @response 401 {
     *   "message": "Unauthenticated"
     * }
     */
    public function user(Request $request)
    {
        return response()->json([
            'user' => $request->user(),
        ]);
    }
}











