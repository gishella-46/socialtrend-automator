<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

/**
 * Prometheus Service Provider
 * 
 * Registers Prometheus exporter if package is installed
 */
class PrometheusServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register(): void
    {
        // Register Prometheus exporter if available
        if (class_exists('\Artisaninweb\PrometheusExporter\PrometheusExporter')) {
            $this->app->singleton('prometheus', function ($app) {
                return new \Artisaninweb\PrometheusExporter\PrometheusExporter();
            });
        }
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot(): void
    {
        //
    }
}








