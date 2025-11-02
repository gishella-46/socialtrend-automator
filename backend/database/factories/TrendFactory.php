<?php

namespace Database\Factories;

use App\Models\Trend;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Trend>
 */
class TrendFactory extends Factory
{
    protected $model = Trend::class;

    public function definition(): array
    {
        return [
            'keyword' => fake()->words(2, true),
            'platform' => fake()->randomElement(['google', 'twitter', 'reddit']),
            'count' => fake()->numberBetween(0, 1000),
        ];
    }
}

