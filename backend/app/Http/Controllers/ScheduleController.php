<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Http\Controllers;

use App\Models\ScheduledPost;
use App\Services\AuditLogService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

/**
 * Schedule Controller
 * 
 * Handles scheduled post endpoints
 * 
 * @group Scheduling
 */
class ScheduleController extends Controller
{
    /**
     * Schedule a new post
     * 
     * @bodyParam social_account_id integer required ID of the social account. Example: 1
     * @bodyParam content string required Post content. Example: Check out this amazing content!
     * @bodyParam scheduled_at string required Scheduled datetime (ISO format, must be in future). Example: 2024-12-25 10:00:00
     * @bodyParam media_urls array optional Array of media URLs. Example: ["https://example.com/image.jpg"]
     * 
     * @response 201 {
     *   "message": "Post scheduled successfully",
     *   "scheduled_post": {
     *     "id": 1,
     *     "user_id": 1,
     *     "social_account_id": 1,
     *     "content": "Check out this amazing content!",
     *     "scheduled_at": "2024-12-25 10:00:00",
     *     "status": "pending"
     *   }
     * }
     * @response 422 {
     *   "message": "The given data was invalid.",
     *   "errors": {
     *     "scheduled_at": ["The scheduled at must be a date after now."]
     *   }
     * }
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'social_account_id' => 'required|exists:social_accounts,id',
            'content' => 'required|string',
            'scheduled_at' => 'required|date|after:now',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
        ]);

        $scheduledPost = ScheduledPost::create([
            'user_id' => $request->user()->id,
            'social_account_id' => $validated['social_account_id'],
            'content' => $validated['content'],
            'scheduled_at' => $validated['scheduled_at'],
            'media_urls' => $validated['media_urls'] ?? [],
            'status' => 'pending',
        ]);

        // Log upload/schedule action
        AuditLogService::log(
            'schedule',
            'ScheduledPost',
            $scheduledPost->id,
            ['platform' => $scheduledPost->socialAccount->platform ?? 'unknown'],
            $request
        );

        // Optionally send to automation service
        // $automationUrl = env('AUTOMATION_SERVICE_URL', 'http://automation:5000');
        // Http::post("{$automationUrl}/schedule", $scheduledPost->toArray());

        return response()->json([
            'message' => 'Post scheduled successfully',
            'scheduled_post' => $scheduledPost,
        ], 201);
    }
}











