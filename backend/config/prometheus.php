<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Prometheus Exporter Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration for Laravel Prometheus Exporter
    |
    */

    'namespace' => env('PROMETHEUS_NAMESPACE', 'laravel'),

    'storage_adapter' => env('PROMETHEUS_STORAGE_ADAPTER', 'redis'),

    'redis' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'port' => env('REDIS_PORT', 6379),
        'password' => env('REDIS_PASSWORD', null),
        'database' => env('REDIS_DATABASE', 0),
    ],

    'default_labels' => [
        'app' => env('APP_NAME', 'laravel'),
        'env' => env('APP_ENV', 'production'),
    ],
];








