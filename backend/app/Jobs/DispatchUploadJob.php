<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Jobs;

use App\Models\ScheduledPost;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Dispatch Upload Job
 * 
 * Job untuk mengirim request ke Python FastAPI /api/upload
 * 
 * @property ScheduledPost $scheduledPost
 */
class DispatchUploadJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public ScheduledPost $scheduledPost
    ) {
        // Set queue connection
        $this->onConnection('redis');
        $this->onQueue('uploads');
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            $automationUrl = env('AUTOMATION_SERVICE_URL', 'http://automation:5000');
            $endpoint = rtrim($automationUrl, '/') . '/api/upload';

            // Update status to processing
            $this->scheduledPost->update([
                'status' => 'processing',
            ]);

            // Prepare payload
            $payload = [
                'scheduled_post_id' => $this->scheduledPost->id,
                'user_id' => $this->scheduledPost->user_id,
                'social_account_id' => $this->scheduledPost->social_account_id,
                'content' => $this->scheduledPost->content,
                'media_urls' => $this->scheduledPost->media_urls ?? [],
                'scheduled_at' => $this->scheduledPost->scheduled_at->toIso8601String(),
                'callback_url' => env('APP_URL') . '/api/upload/callback',
            ];

            // Send request to Python FastAPI
            $response = Http::timeout(30)
                ->post($endpoint, $payload);

            if ($response->successful()) {
                Log::info('Upload job dispatched successfully', [
                    'scheduled_post_id' => $this->scheduledPost->id,
                    'response' => $response->json(),
                ]);
            } else {
                throw new \Exception('Upload request failed: ' . $response->body());
            }
        } catch (\Exception $e) {
            // Update status to failed
            $this->scheduledPost->update([
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);

            Log::error('Upload job failed', [
                'scheduled_post_id' => $this->scheduledPost->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}


















