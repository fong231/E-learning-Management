<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::create('chat_rooms', function (Blueprint $table) {
            $table->increments('message_id');
            $table->text('message')->nullable();
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->timestamp('updated_at')->nullable();
            $table->boolean('is_important')->default(0);

            $table->integer('project_id')->unsigned();
            $table->integer('sender_id')->unsigned()->nullable();
            $table->integer('content_id')->unsigned()->nullable();

            $table->foreign('project_id')
                  ->references('project_id')->on('projects')
                  ->onDelete('cascade');

            $table->foreign('sender_id')
                  ->references('customer_id')->on('customers')
                  ->onDelete('set null');

            $table->foreign('content_id')
                  ->references('content_id')->on('contents')
                  ->onDelete('set null');
        });

        Schema::create('chat_privates', function (Blueprint $table) {
            $table->increments('message_id');
            $table->text('message')->nullable();
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->timestamp('updated_at')->nullable();
            $table->boolean('is_read')->default(0);
            $table->boolean('is_important')->default(0);

            $table->integer('project_id')->unsigned();
            $table->integer('sender_id')->unsigned()->nullable();
            $table->integer('receiver_id')->unsigned()->nullable();
            $table->integer('content_id')->unsigned()->nullable();

            $table->foreign('project_id')
                  ->references('project_id')->on('projects')
                  ->onDelete('cascade');
                  
            $table->foreign('sender_id')
                  ->references('customer_id')->on('customers')
                  ->onDelete('set null');
            
            $table->foreign('receiver_id')
                  ->references('customer_id')->on('customers')
                  ->onDelete('set null');      

            $table->foreign('content_id')
                  ->references('content_id')->on('contents')
                  ->onDelete('set null');
        });
    }

    public function down(): void {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        Schema::dropIfExists('chat_rooms');
        Schema::dropIfExists('chat_privates');
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};
