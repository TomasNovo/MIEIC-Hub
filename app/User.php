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
        'name', 'email', 'password', 'birth_date', 'id_photo'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

    public static function isAuthMod()
    {
        return Auth::user() != null && Auth::user()->isMod();
    }

    public function isAuthenticatedUser()
    {
        if(Auth::user() != null)
            return $this->id == Auth::id();
        else
            return false;
    }

    public function isMod()
    {
        return $this->moderator;
    }

    public function isStockManager()
    {
        return $this->stock_manager;
    }

    public function isSubManager()
    {
        return $this->submission_manager;
    }

    public static function getURLUser($name)
    {
        $user = User::where('name', $name)->get();

        if(count($user) == 0)
        {
            $user = User::where('name', Utils::reverse_slug($name))->get();

            if(count($user) == 0)
                return redirect('/error/404');
        }

        return $user[0];
    }

    public function getPhoto($path)
    {
        $photo = Photo::find($this->id_photo);

        if($path)
            return $photo->image_path;
        else
            return $photo;
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

    public function getOrders()
    {
        return DB::select(DB::raw
        (
            "SELECT DISTINCT product.id_product, product.product_name, product_purchase.price, product_purchase.quantity, purchase.purchase_date, purchase.status
            FROM users, purchase, product_purchase, product
            WHERE users.id = " . $this->id .
            " AND users.id = purchase.id_user 
            AND product_purchase.id_purchase = purchase.id_purchase 
            AND product_purchase.id_product = product.id_product"
        ));
    }

    public function updateSetting($setting, $value)
    {
        DB::table('users')
            ->where('id', $this->id)
            ->update([$setting => $value]);
    }

    public function getCartItems()
    {
        return DB::select(DB::raw
        (
            "SELECT cart.id_cart, product.id_product, product_name, price, quantity, id_size, id_color
            FROM users, product, cart
            WHERE users.id = " . $this->id . "AND users.id = cart.id_user AND
            cart.id_product = product.id_product"

        ));
    }

    public static function getCities()
    {
        return DB::select(DB::raw
        (
            "SELECT city
            FROM city"
        ));
    }

    public static function getLastInfo()
    {
        return DB::select(DB::raw
        (
            "SELECT id_delivery_info FROM delivery_info ORDER BY id_delivery_info DESC LIMIT 1"
        ))[0];
    }

    public static function search($query)
    {
        return DB::select(DB::raw
        (
            "SELECT users.id, users.name, users.email, image_path, ts_rank_cd(text_search, query) AS rank
            FROM users, photo,  plainto_tsquery('" . $query . "') AS query, to_tsvector(users.name) AS text_search
            WHERE users.id_photo = photo.id_photo 
            AND text_search @@ query
            ORDER BY rank DESC"
        ));
    }

    public function setPrivilege($role, $value)
    {
        $this->$role = $value;
        $this->save();
    }

}
