<?php

namespace App;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class Utils
{
    public static function saveImage(UploadedFile $uploadedFile, $folder = null, $disk = 'public', $filename = null)
    {
        $name = !is_null($filename) ? $filename : str_random(25);

        $file = $uploadedFile->storeAs($folder, $name.'.'.$uploadedFile->getClientOriginalExtension(), $disk);

        return $file;
    }

    public static function deleteImage($path, $disk = 'public')
    {
        Storage::disk($disk)->delete($path);
    }

    public static function slug($title, $separator = '-')
    {
        // Convert all dashes/underscores into separator
        $flip = $separator == '-' ? '_' : '-';
        $title = preg_replace('!['.preg_quote($flip).']+!u', $separator, $title);
        // Replace @ with the word 'at'
        $title = str_replace('@', $separator.'at'.$separator, $title);
        // Remove all characters that are not the separator, letters, numbers, or whitespace.

        // With lower case: $title = preg_replace('![^'.preg_quote($separator).'\pL\pN\s]+!u', '', mb_strtolower($title));
        $title = preg_replace('![^'.preg_quote($separator).'\pL\pN\s]+!u', '', $title);

        // Replace all separator characters and whitespace by a single separator
        $title = preg_replace('!['.preg_quote($separator).'\s]+!u', $separator, $title);
        return trim($title, $separator);
    }

    public static function reverse_slug($title)
    {
        return str_replace('-', ' ', $title);
    }

    public static function replaceWhiteSpace($path)
    {
        return str_replace(' ', '%20', $path);
    }
}
