<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Create scheduled posts table migration
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('scheduled_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('social_account_id')->constrained()->onDelete('cascade');
            $table->text('content');
            $table->json('media_urls')->nullable();
            $table->timestamp('scheduled_at');
            $table->enum('status', ['pending', 'processing', 'posted', 'failed'])->default('pending');
            $table->text('error_message')->nullable();
            $table->timestamp('posted_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status']);
            $table->index(['scheduled_at', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('scheduled_posts');
    }
};


















