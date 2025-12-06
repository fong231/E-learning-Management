<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::create('projects', function (Blueprint $table) {
            $table->increments('project_id');
            $table->string('name');
            $table->text('description')->nullable();
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->integer('owner_id')->unsigned();

            $table->foreign('owner_id')
                  ->references('customer_id')->on('customers')
                  ->onDelete('cascade');
        });

        Schema::create('project_members', function (Blueprint $table) {
            $table->integer('project_id')->unsigned();
            $table->integer('member_id')->unsigned();
            $table->enum('role', ['manager', 'member'])->default('member');

            $table->primary(['project_id', 'member_id']);

            $table->foreign('project_id')
                  ->references('project_id')->on('projects')
                  ->onDelete('cascade');

            $table->foreign('member_id')
                  ->references('customer_id')->on('customers')
                  ->onDelete('cascade');
        });
    }

    public function down(): void {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        Schema::dropIfExists('projects');
        Schema::dropIfExists('project_members');
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};
