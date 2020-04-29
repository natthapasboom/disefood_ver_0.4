<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Requests\CreateUserStore;
use App\Repositories\Interfaces\UserRepositoryInterface;
use App\Repositories\Interfaces\ProfileRepositoryInterface;
use App\Repositories\Interfaces\UserShopsRepositoryInterface;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{

    private $userRepo;
    private $profileRepo;
    private $userShopRepo;

    public function __construct
    (
        UserRepositoryInterface $userRepo,
        ProfileRepositoryInterface $profileRepo,
        UserShopsRepositoryInterface $userShopsRepo
    )
    {
        $this->userRepo = $userRepo;
        $this->profileRepo = $profileRepo;
        $this->userShopRepo = $userShopsRepo;
    }

    public function getUserById($user_id)
    {
        return $this->userRepo->getUserById($user_id);
    }

    public function getProfileById($user_id)
    {
        return $this->profileRepo->getProfileById($user_id);
    }

    public function getShopByUserId($user_id)
    {
        return $this->userShopRepo->getShopByUserId($user_id);
    }

    public function register(CreateUserStore $request)
    {
        $newUser = $request->validated();
        if($request->hasFile('profile_img')) {
            $path = $user['profile_img'] = Storage::disk('s3')->put('images/user/profile_img', $request->file('profile_img'));
        }
        $newUser['password'] = bcrypt($newUser['password']);
        $user = $this->userRepo->create($newUser);
        $user_id = $user['user_id'];
        return $this->profileRepo->create($newUser , $user_id);
    }
}
