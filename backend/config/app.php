<?php

/**
 * Application Configuration
 * 
 * This file contains the application configuration.
 * Environment variables are loaded via .env file.
 */

/** @var array */
return [
    'name' => getenv('APP_NAME') ?: 'SocialTrend Automator',
    'env' => getenv('APP_ENV') ?: 'production',
    'debug' => filter_var(getenv('APP_DEBUG') ?: false, FILTER_VALIDATE_BOOLEAN),
    'url' => getenv('APP_URL') ?: 'http://localhost',
    'timezone' => getenv('APP_TIMEZONE') ?: 'UTC',
    'locale' => getenv('APP_LOCALE') ?: 'en',
    'fallback_locale' => getenv('APP_FALLBACK_LOCALE') ?: 'en',
    'faker_locale' => getenv('APP_FAKER_LOCALE') ?: 'en_US',
    'key' => getenv('APP_KEY') ?: '',
    'cipher' => 'AES-256-CBC',
];

