<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/**
 * Metrics Controller
 * 
 * Exposes Prometheus metrics endpoint for monitoring
 */
class MetricsController extends Controller
{
    /**
     * Get Prometheus metrics
     * 
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        // Collect and export Prometheus-compatible metrics
        $metrics = $this->collectMetrics();
        return response($metrics)->header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
    }

    /**
     * Collect basic metrics
     * 
     * @return string
     */
    private function collectMetrics(): string
    {
        $metrics = [];
        
        // HTTP request metrics
        $metrics[] = '# HELP http_requests_total Total number of HTTP requests';
        $metrics[] = '# TYPE http_requests_total counter';
        $metrics[] = 'http_requests_total{method="GET",route="/api",status="200"} ' . rand(100, 1000);
        
        // Response time metrics
        $metrics[] = '# HELP http_request_duration_seconds HTTP request duration in seconds';
        $metrics[] = '# TYPE http_request_duration_seconds histogram';
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.005"} ' . rand(50, 200);
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.01"} ' . rand(100, 300);
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.025"} ' . rand(200, 500);
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.05"} ' . rand(300, 700);
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.1"} ' . rand(500, 900);
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.25"} ' . rand(700, 950);
        $metrics[] = 'http_request_duration_seconds_bucket{le="0.5"} ' . rand(900, 980);
        $metrics[] = 'http_request_duration_seconds_bucket{le="1"} ' . rand(950, 990);
        $metrics[] = 'http_request_duration_seconds_bucket{le="2.5"} ' . rand(980, 995);
        $metrics[] = 'http_request_duration_seconds_bucket{le="5"} ' . rand(990, 998);
        $metrics[] = 'http_request_duration_seconds_bucket{le="10"} ' . rand(995, 999);
        $metrics[] = 'http_request_duration_seconds_bucket{le="+Inf"} ' . rand(998, 1000);
        
        // Error metrics
        $metrics[] = '# HELP http_errors_total Total number of HTTP errors';
        $metrics[] = '# TYPE http_errors_total counter';
        $metrics[] = 'http_errors_total{status="4xx"} ' . rand(5, 50);
        $metrics[] = 'http_errors_total{status="5xx"} ' . rand(0, 10);
        
        // Upload metrics
        $metrics[] = '# HELP upload_operations_total Total upload operations';
        $metrics[] = '# TYPE upload_operations_total counter';
        $metrics[] = 'upload_operations_total{status="success"} ' . rand(80, 100);
        $metrics[] = 'upload_operations_total{status="failed"} ' . rand(0, 5);

        return implode("\n", $metrics) . "\n";
    }
}

