<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::create('customers', function (Blueprint $table) {
            $table->increments('customer_id');
            $table->string('full_name');
            $table->string('email');
            $table->string('password');
            $table->string('avatar')->nullable();
            $table->string('nickname')->nullable();
            
            $table->timestamp('email_verified_at')->nullable();
            $table->string('verification_token', 64)->nullable();
            $table->timestamp('verification_token_expires_at')->nullable();
            $table->string('reset_token', 64)->nullable();
            $table->timestamp('reset_token_expires_at')->nullable();
        });
    }

    public function down(): void {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        Schema::dropIfExists('customers');

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};
