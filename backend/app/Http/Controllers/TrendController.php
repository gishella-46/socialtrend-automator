<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Http\Controllers;

use App\Models\Trend;
use Illuminate\Http\Request;

/**
 * Trend Controller
 * 
 * Handles trend-related endpoints
 * 
 * @group Trends
 */
class TrendController extends Controller
{
    /**
     * Get trends
     * 
     * Retrieve paginated list of trends from the database.
     * 
     * @queryParam page integer The page number. Example: 1
     * @queryParam per_page integer Items per page. Example: 20
     * 
     * @response 200 {
     *   "trends": {
     *     "current_page": 1,
     *     "data": [
     *       {
     *         "id": 1,
     *         "keyword": "AI Technology",
     *         "platform": "google",
     *         "score": 85,
     *         "created_at": "2024-01-01T00:00:00.000000Z"
     *       }
     *     ],
     *     "per_page": 20,
     *     "total": 100
     *   }
     * }
     * @response 401 {
     *   "message": "Unauthenticated"
     * }
     */
    public function index(Request $request)
    {
        $trends = Trend::orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'trends' => $trends,
        ]);
    }
}











