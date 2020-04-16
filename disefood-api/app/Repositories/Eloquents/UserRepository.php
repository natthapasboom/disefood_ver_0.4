<?php


namespace App\Repositories\Eloquents;
use App\Repositories\Interfaces\UserRepositoryInterface;
use App\Models\User\User;

class UserRepository implements UserRepositoryInterface
{
    public function __construct()
    {
        $this->user = new User;
    }

    public function getUserById($user_id)
    {
        return $this->user->where('user_id', $user_id)->first();
    }
}
