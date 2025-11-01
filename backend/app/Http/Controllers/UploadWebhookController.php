<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Http\Controllers;

use App\Models\ScheduledPost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * Upload Webhook Controller
 * 
 * Controller untuk menerima callback dari Python FastAPI service
 * Update status scheduled post berdasarkan hasil upload
 */
class UploadWebhookController extends Controller
{
    /**
     * Handle upload callback from Python service
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function callback(Request $request)
    {
        $validated = $request->validate([
            'scheduled_post_id' => 'required|integer|exists:scheduled_posts,id',
            'status' => 'required|string|in:posted,failed',
            'message' => 'nullable|string',
            'post_url' => 'nullable|url',
            'error' => 'nullable|string',
        ]);

        try {
            $scheduledPost = ScheduledPost::findOrFail($validated['scheduled_post_id']);

            if ($validated['status'] === 'posted') {
                // Update to posted
                $scheduledPost->update([
                    'status' => 'posted',
                    'posted_at' => now(),
                    'error_message' => null,
                ]);

                Log::info('Scheduled post uploaded successfully', [
                    'scheduled_post_id' => $scheduledPost->id,
                    'post_url' => $validated['post_url'] ?? null,
                    'message' => $validated['message'] ?? null,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Scheduled post status updated to posted',
                    'data' => [
                        'scheduled_post_id' => $scheduledPost->id,
                        'status' => 'posted',
                        'posted_at' => $scheduledPost->posted_at,
                    ],
                ]);
            } else {
                // Update to failed
                $errorMessage = $validated['error'] ?? $validated['message'] ?? 'Upload failed';

                $scheduledPost->update([
                    'status' => 'failed',
                    'error_message' => $errorMessage,
                ]);

                Log::warning('Scheduled post upload failed', [
                    'scheduled_post_id' => $scheduledPost->id,
                    'error' => $errorMessage,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Scheduled post status updated to failed',
                    'data' => [
                        'scheduled_post_id' => $scheduledPost->id,
                        'status' => 'failed',
                        'error_message' => $errorMessage,
                    ],
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Error processing upload webhook', [
                'error' => $e->getMessage(),
                'request_data' => $validated,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error processing webhook: ' . $e->getMessage(),
            ], 500);
        }
    }
}

