<?php

namespace App\Http\Controllers\Api;

use App\Helpers\AuthHelper;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class ProfileApiController
{
    public function update(Request $request)
    {
        $customerId = AuthHelper::getCustomerId($request);
        $user = Customer::find($customerId);

        // Validate dữ liệu đầu vào
        $validated = $request->validate([
            'fullname' => ['required', 'string', 'max:255'],
            'nickname' => ['nullable', 'string', 'max:50', 'unique:customers,nickname,' . $user->customer_id . ',customer_id'], // Bỏ qua check unique cho chính user này
            'avatar'   => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'], // Max 2MB
        ]);

        // Cập nhật thông tin cơ bản
        $user->full_name = $validated['fullname'];
        $user->nickname = $validated['nickname'] ?? null;

        // Xử lý Upload Avatar
        if ($request->hasFile('avatar')) {
            // Xóa avatar cũ 
            if ($user->avatar && Storage::disk('public')->exists(str_replace('/storage/', '', $user->avatar))) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $user->avatar));
            }

            // Lưu file mới vào folder 'avatars' trong disk public
            $path = $request->file('avatar')->store('avatars', 'public');
            
            // Lưu đường dẫn có thể truy cập từ browser vào DB
            $user->avatar = '/storage/' . $path;
        }

        /** @var \App\Models\Customer $user */
        $user->save();
        return back()->with('success', 'Profile updated successfully!');
    }

    /**
     * Đổi mật khẩu.
     */
    public function updatePassword(Request $request)
    {
        try {
            $customerId = AuthHelper::getCustomerId($request);
            $user = Customer::find($customerId);

            // Validate mật khẩu
            $validated = $request->validate([
                'current_password' => ['required'],
                'password' => ['required', 'confirmed', 'min:6', 'different:current_password'],
            ]);

            if (!Hash::check($validated['current_password'], $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Current password is incorrect',
                ], 400);
            }

            $user->password = Hash::make($validated['password']);
            $user->save();

            return back()->with('success', 'Password changed successfully!');
        } catch (\Exception $e) {
            Log::error($e->getMessage());
        }
    }
}