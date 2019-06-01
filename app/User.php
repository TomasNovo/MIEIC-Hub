<?php

namespace App;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Facades\Auth;
use App\Photo;
use Illuminate\Support\Facades\DB;

class User extends Authenticatable
{
    use Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    protected $table = 'users';
    protected $primaryKey = 'id';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password', 'birth_date'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

    public function isAuthenticatedUser()
    {
        return $this->id == Auth::id();
    }

    public function isMod()
    {
        return $this->moderator;
    }

    public function getPhotoPath()
    {
        return Photo::find($this->id_photo)->image_path;
    }

    public function getReviews()
    {
        return DB::select(DB::raw
        (
            "SELECT DISTINCT product.id_product, product.product_name, review.review_date, review.comment, review.rating
            FROM users, product, review
            WHERE users.id = " . $this->id . 
            " AND users.id = review.id_user 
            AND product.id_product = review.id_product"
        ));
    }

}
