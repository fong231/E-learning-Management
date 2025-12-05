<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Customer;
use Illuminate\Support\Facades\Hash;

class TestUserSeeder extends Seeder
{
    public function run(): void
    {
        // Create test user if not exists
        if (!Customer::where('email', 'test@test.com')->exists()) {
            Customer::create([
                'full_name' => 'Test User',
                'email' => 'test@test.com',
                'password' => Hash::make('password123'),
            ]);
            
            echo "Test user created: test@test.com / password123\n";
        } else {
            echo "Test user already exists\n";
        }
    }
}

