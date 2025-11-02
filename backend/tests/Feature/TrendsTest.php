<?php

namespace Tests\Feature;

use App\Models\Trend;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TrendsTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_fetch_trends(): void
    {
        $user = User::factory()->create();
        Trend::factory()->count(5)->create();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/trends');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'trends' => [
                'current_page',
                'data',
                'per_page',
                'total',
            ],
        ]);
    }

    public function test_unauthorized_user_cannot_fetch_trends(): void
    {
        $response = $this->getJson('/api/trends');

        $response->assertStatus(401);
    }

    public function test_trends_are_paginated(): void
    {
        $user = User::factory()->create();
        Trend::factory()->count(25)->create();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/trends');

        $response->assertStatus(200);
        $this->assertCount(20, $response->json('trends.data'));
    }
}

