<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Create trends table migration
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('trends', function (Blueprint $table) {
            $table->id();
            $table->string('platform'); // instagram, twitter, facebook, tiktok, etc.
            $table->string('keyword');
            $table->integer('count')->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['platform', 'keyword']);
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('trends');
    }
};


















