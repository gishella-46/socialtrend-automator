<?php
/** @phpstan-ignore-file */
/** @phpcs:ignoreFile */

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Scheduled Post Model
 * 
 * @property int $id
 * @property int $user_id
 * @property int $social_account_id
 * @property string $content
 * @property array|null $media_urls
 * @property \Carbon\Carbon $scheduled_at
 * @property string $status
 * @property string|null $error_message
 * @property \Carbon\Carbon|null $posted_at
 * @property \Carbon\Carbon|null $created_at
 * @property \Carbon\Carbon|null $updated_at
 */
class ScheduledPost extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'social_account_id',
        'content',
        'media_urls',
        'scheduled_at',
        'status',
        'error_message',
        'posted_at',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'media_urls' => 'array',
            'scheduled_at' => 'datetime',
            'posted_at' => 'datetime',
        ];
    }

    /**
     * Get the user that owns the scheduled post
     * 
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the social account for this scheduled post
     * 
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function socialAccount()
    {
        return $this->belongsTo(SocialAccount::class);
    }
}


















