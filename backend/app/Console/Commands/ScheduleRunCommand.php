<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Console\Commands;

use App\Jobs\DispatchUploadJob;
use App\Models\ScheduledPost;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

/**
 * Schedule Run Command
 * 
 * Command untuk push task ke Redis setiap menit
 * Mengecek scheduled posts yang sudah waktunya di-upload
 */
class ScheduleRunCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'schedule:run';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Push scheduled upload tasks to Redis queue';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $this->info('Running schedule:run...');

        try {
            // Get scheduled posts that are ready to be uploaded
            // (scheduled_at <= now() and status = 'pending')
            $readyPosts = ScheduledPost::where('status', 'pending')
                ->where('scheduled_at', '<=', now())
                ->with(['user', 'socialAccount'])
                ->get();

            if ($readyPosts->isEmpty()) {
                $this->info('No scheduled posts ready for upload.');
                return Command::SUCCESS;
            }

            $this->info("Found {$readyPosts->count()} scheduled post(s) ready for upload.");

            $dispatched = 0;
            foreach ($readyPosts as $post) {
                // Dispatch job to queue
                DispatchUploadJob::dispatch($post);
                $dispatched++;

                $this->line("Dispatched upload job for scheduled post ID: {$post->id}");
                Log::info('Scheduled post dispatched to queue', [
                    'scheduled_post_id' => $post->id,
                    'user_id' => $post->user_id,
                    'scheduled_at' => $post->scheduled_at,
                ]);
            }

            $this->info("Successfully dispatched {$dispatched} job(s) to Redis queue.");
            return Command::SUCCESS;
        } catch (\Exception $e) {
            $this->error('Error running schedule: ' . $e->getMessage());
            Log::error('Schedule run failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return Command::FAILURE;
        }
    }
}


















