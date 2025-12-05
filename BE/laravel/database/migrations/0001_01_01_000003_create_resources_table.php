<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::create('contents', function (Blueprint $table) {
            $table->increments('content_id');
            $table->enum('type', ['chat_private','chat_room','task']);
        });

        Schema::create('resources', function (Blueprint $table) {
            $table->increments('resource_id');
            $table->string('path')->nullable();
            $table->enum('type', ['file', 'image']);
            $table->integer('size');
            $table->string('file_name');
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));

            $table->integer('uploaded_by')->unsigned()->nullable();
            $table->integer('content_id')->unsigned();

            $table->foreign('uploaded_by')
                  ->references('customer_id')->on('customers')
                  ->onDelete('set null');

            $table->foreign('content_id')
                  ->references('content_id')->on('contents')
                  ->onDelete('cascade');
        });
    }

    public function down(): void {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        Schema::dropIfExists('contents');
        Schema::dropIfExists('resources');
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};
