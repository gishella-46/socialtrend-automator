<?php
/** @phpstan-ignore-next-line */
/** @phpstan-ignore-next-line */

/**
 * Application Service Provider
 *
 * This service provider is where you may register all of your
 * application services. All service providers are bootstrapped
 * by Laravel's service container.
 */

namespace App\Providers;

/** @phpstan-ignore-next-line */
use Illuminate\Support\ServiceProvider;

/** @phpstan-ignore-next-line */
class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot(): void
    {
        // Application bootstrapping
    }
}
