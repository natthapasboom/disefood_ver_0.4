<?php


namespace App\Repositories\Eloquents;

use App\Models\Shop\Food;
use App\Models\Shop\Shop;
use App\Repositories\Interfaces\FoodRepositoryInterface;

class FoodRepository implements FoodRepositoryInterface
{
    private $food;

    public function __construct()
    {
        $this->food = new Food();
    }

    public function get()
    {
        return $this->food->all();
    }

    public function findByFoodId($foodId)
    {
        return $this->food->where('id', $foodId)->first();
    }

    public function update($food, $foodId)
    {
        return $this->food->where('id', $foodId)->update($food);
    }

    public function delete($foodId)
    {
        return $this->food->where('id', $foodId)->delete();
    }

    public function addMenuByShopId($newMenu, $shopId)
    {
        $shop = Shop::find($shopId);
        $this->food->shop()->associate($shop);

        $this->food->name = $newMenu['name'];
        $this->food->price = $newMenu['price'];
        $this->food->status = $newMenu['status'];
        $this->food->cover_img = $newMenu['cover_img'];

        $this->food->save($newMenu);
        return $this->food;
    }
}
