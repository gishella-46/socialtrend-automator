<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Models;

use App\Services\EncryptionService;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Social Account Model
 * 
 * @property int $id
 * @property int $user_id
 * @property string $platform
 * @property string $username
 * @property string|null $access_token
 * @property string|null $refresh_token
 * @property \Carbon\Carbon|null $token_expires_at
 * @property bool $is_active
 * @property \Carbon\Carbon|null $created_at
 * @property \Carbon\Carbon|null $updated_at
 */
class SocialAccount extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'platform',
        'username',
        'access_token',
        'refresh_token',
        'token_expires_at',
        'is_active',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'token_expires_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    /**
     * Get the user that owns the social account
     * 
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get scheduled posts for this social account
     * 
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function scheduledPosts()
    {
        return $this->hasMany(ScheduledPost::class);
    }

    /**
     * Encrypt access token before saving
     * 
     * @param string|null $value
     * @return void
     */
    public function setAccessTokenAttribute($value): void
    {
        if (!empty($value)) {
            $this->attributes['access_token'] = EncryptionService::encrypt($value);
        } else {
            $this->attributes['access_token'] = null;
        }
    }

    /**
     * Decrypt access token when retrieving
     * 
     * @param string|null $value
     * @return string|null
     */
    public function getAccessTokenAttribute($value): ?string
    {
        if (empty($value)) {
            return null;
        }

        try {
            return EncryptionService::decrypt($value);
        } catch (\Exception $e) {
            \Log::error('Failed to decrypt access token', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Encrypt refresh token before saving
     * 
     * @param string|null $value
     * @return void
     */
    public function setRefreshTokenAttribute($value): void
    {
        if (!empty($value)) {
            $this->attributes['refresh_token'] = EncryptionService::encrypt($value);
        } else {
            $this->attributes['refresh_token'] = null;
        }
    }

    /**
     * Decrypt refresh token when retrieving
     * 
     * @param string|null $value
     * @return string|null
     */
    public function getRefreshTokenAttribute($value): ?string
    {
        if (empty($value)) {
            return null;
        }

        try {
            return EncryptionService::decrypt($value);
        } catch (\Exception $e) {
            \Log::error('Failed to decrypt refresh token', ['error' => $e->getMessage()]);
            return null;
        }
    }
}











