<?php

namespace Tests\Feature;

use App\Models\ScheduledPost;
use App\Models\SocialAccount;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScheduleTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_schedule_post(): void
    {
        $user = User::factory()->create();
        $socialAccount = SocialAccount::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/schedule', [
                'social_account_id' => $socialAccount->id,
                'content' => 'This is a test post',
                'scheduled_at' => now()->addDay()->toDateTimeString(),
            ]);

        $response->assertStatus(201);
        $response->assertJsonStructure([
            'message',
            'scheduled_post' => ['id', 'user_id', 'social_account_id', 'content', 'scheduled_at', 'status'],
        ]);

        $this->assertDatabaseHas('scheduled_posts', [
            'user_id' => $user->id,
            'content' => 'This is a test post',
        ]);
    }

    public function test_user_cannot_schedule_past_date(): void
    {
        $user = User::factory()->create();
        $socialAccount = SocialAccount::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/schedule', [
                'social_account_id' => $socialAccount->id,
                'content' => 'This is a test post',
                'scheduled_at' => now()->subDay()->toDateTimeString(),
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['scheduled_at']);
    }

    public function test_unauthorized_user_cannot_schedule_post(): void
    {
        $response = $this->postJson('/api/schedule', [
            'social_account_id' => 1,
            'content' => 'This is a test post',
            'scheduled_at' => now()->addDay()->toDateTimeString(),
        ]);

        $response->assertStatus(401);
    }

    public function test_scheduled_post_requires_valid_social_account(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/schedule', [
                'social_account_id' => 999999,
                'content' => 'This is a test post',
                'scheduled_at' => now()->addDay()->toDateTimeString(),
            ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['social_account_id']);
    }
}

