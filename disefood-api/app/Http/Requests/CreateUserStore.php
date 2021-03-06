<?php

namespace App\Http\Requests;

use Illuminate\Http\Request;

class CreateUserStore extends BaseFormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules(Request $request)
    {
        return [
            'username'          => 'required|string|min:4|max:50|unique:users,username',
            'password'          => 'required|string|min:6|max:50',
            'email'             => 'required|string|min:6|max:50|unique:users,email',
            'first_name'        => 'required|string|max:50',
            'last_name'         => 'required|string|max:50',
            'tel'               => 'required|string|min:10|max:10|unique:users,tel',
            'profile_img'       => 'image',
            'role'              => 'required|string',
        ];
    }
}
