<?php
/** @phpstan-ignore-next-line */
/** @phpstan-ignore-next-line */

/**
 * Console Routes
 * 
 * Here is where you can register Closure based console commands.
 */

/** @phpstan-ignore-next-line */
use Illuminate\Foundation\Inspiring;
/** @phpstan-ignore-next-line */
use Illuminate\Support\Facades\Artisan;
/** @phpstan-ignore-next-line */
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    /** @phpstan-ignore-next-line */
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

// Schedule: Run every minute to push tasks to Redis queue
/** @phpstan-ignore-next-line */
use App\Console\Commands\ScheduleRunCommand;

Schedule::command(ScheduleRunCommand::class)->everyMinute();

