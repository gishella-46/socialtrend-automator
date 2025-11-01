<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\AuditLogService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Auth Controller
 * 
 * Handles authentication endpoints
 * 
 * @group Authentication
 */
class AuthController extends Controller
{
    /**
     * Register a new user
     * 
     * @bodyParam name string required User's full name. Example: John Doe
     * @bodyParam email string required User's email address. Example: john@example.com
     * @bodyParam password string required User's password (min 8 characters). Example: password123
     * @bodyParam password_confirmation string required Password confirmation. Example: password123
     * 
     * @response 201 {
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com"
     *   },
     *   "token": "1|xxxxxxxxxxxxx"
     * }
     * @response 422 {
     *   "message": "The given data was invalid.",
     *   "errors": {
     *     "email": ["The email has already been taken."]
     *   }
     * }
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        // Log registration
        AuditLogService::log('register', 'User', $user->id, ['email' => $user->email], $request);

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    /**
     * Login user
     * 
     * @bodyParam email string required User's email address. Example: john@example.com
     * @bodyParam password string required User's password. Example: password123
     * 
     * @response 200 {
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com"
     *   },
     *   "token": "1|xxxxxxxxxxxxx"
     * }
     * @response 422 {
     *   "message": "The provided credentials are incorrect."
     * }
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            // Log failed login attempt
            if ($user) {
                AuditLogService::logLogin($user->id, false, $request);
            }
            
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Log successful login
        AuditLogService::logLogin($user->id, true, $request);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }
}
