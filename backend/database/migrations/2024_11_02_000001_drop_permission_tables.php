<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

/**
 * Drop permission tables migration
 * 
 * This migration removes Spatie Permission package tables since this application
 * uses flat access control (all authenticated users have full access).
 * 
 * NOTE: This is optional - you can keep the tables if you want, they just won't be used.
 * If you keep them, Spatie Permission package can remain installed but unused.
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Drop permission-related tables if they exist
        // Uncomment these lines if you want to completely remove permission tables
        
        // Schema::dropIfExists('model_has_permissions');
        // Schema::dropIfExists('model_has_roles');
        // Schema::dropIfExists('role_has_permissions');
        // Schema::dropIfExists('roles');
        // Schema::dropIfExists('permissions');
        
        // NOTE: Currently commented out to preserve existing data structure
        // If you're sure you don't need these tables, uncomment the lines above
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // This migration doesn't create anything, so nothing to rollback
        // If you need to recreate permission tables, run:
        // php artisan migrate:refresh --path=database/migrations/2024_01_01_000004_create_permission_tables.php
    }
};

