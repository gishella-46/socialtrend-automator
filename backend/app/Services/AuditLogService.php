<?php

namespace App\Services;

use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * Audit Log Service
 * 
 * Handles logging of user activities for security auditing
 */
class AuditLogService
{
    /**
     * Log user activity
     * 
     * @param string $action (login, logout, upload, edit, delete, etc.)
     * @param string|null $resourceType
     * @param int|null $resourceId
     * @param array|null $metadata
     * @param Request|null $request
     * @return void
     */
    public static function log(
        string $action,
        ?string $resourceType = null,
        ?int $resourceId = null,
        ?array $metadata = null,
        ?Request $request = null
    ): void {
        $userId = Auth::id();
        
        if (!$userId) {
            return;
        }

        $request = $request ?? request();

        AuditLog::create([
            'user_id' => $userId,
            'action' => $action,
            'resource_type' => $resourceType,
            'resource_id' => $resourceId,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'metadata' => $metadata,
        ]);
    }

    /**
     * Log login attempt
     * 
     * @param int $userId
     * @param bool $success
     * @param Request|null $request
     * @return void
     */
    public static function logLogin(int $userId, bool $success, ?Request $request = null): void
    {
        $request = $request ?? request();

        AuditLog::create([
            'user_id' => $userId,
            'action' => $success ? 'login_success' : 'login_failed',
            'resource_type' => null,
            'resource_id' => null,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'metadata' => [
                'success' => $success,
                'email' => $request->input('email'),
            ],
        ]);
    }

    /**
     * Log upload action
     * 
     * @param int $userId
     * @param string $platform
     * @param Request|null $request
     * @return void
     */
    public static function logUpload(int $userId, string $platform, ?Request $request = null): void
    {
        $request = $request ?? request();

        AuditLog::create([
            'user_id' => $userId,
            'action' => 'upload',
            'resource_type' => 'ScheduledPost',
            'resource_id' => null,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'metadata' => [
                'platform' => $platform,
            ],
        ]);
    }
}








