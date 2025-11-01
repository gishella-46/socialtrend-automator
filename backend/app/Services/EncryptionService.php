<?php

namespace App\Services;

use Illuminate\Support\Facades\Crypt;
use Illuminate\Encryption\Encrypter;

/**
 * Encryption Service
 * 
 * Handles AES-256 encryption/decryption for sensitive data like social media tokens
 */
class EncryptionService
{
    /**
     * Encrypt data using AES-256
     * 
     * @param string $data
     * @return string
     */
    public static function encrypt(string $data): string
    {
        if (empty($data)) {
            return $data;
        }

        // Use Laravel's Crypt facade which uses AES-256-CBC by default
        return Crypt::encryptString($data);
    }

    /**
     * Decrypt data using AES-256
     * 
     * @param string $encryptedData
     * @return string
     */
    public static function decrypt(string $encryptedData): string
    {
        if (empty($encryptedData)) {
            return $encryptedData;
        }

        try {
            return Crypt::decryptString($encryptedData);
        } catch (\Exception $e) {
            // If decryption fails, return empty string
            \Log::error('Decryption failed', ['error' => $e->getMessage()]);
            return '';
        }
    }
}








