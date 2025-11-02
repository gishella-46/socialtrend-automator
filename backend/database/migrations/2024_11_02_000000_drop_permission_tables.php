<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Drop permission tables migration
 *
 * Removes role-based access control tables since all users now have full access
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Drop pivot tables first (foreign key constraints)
        Schema::dropIfExists('model_has_permissions');
        Schema::dropIfExists('model_has_roles');
        Schema::dropIfExists('role_has_permissions');

        // Drop main tables
        Schema::dropIfExists('permissions');
        Schema::dropIfExists('roles');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Note: This won't recreate the exact structure from Spatie Permission
        // If you need to rollback, you'll need to re-run the original migration
        // For now, we'll leave this empty as per requirement to remove RBAC
    }
};
