<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::create('tasks', function (Blueprint $table) {
            $table->increments('task_id');
            $table->text('title');
            $table->text('description')->nullable();
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->timestamp('updated_at')->nullable();
            $table->timestamp('due_date')->nullable();
            $table->enum('priority', ['low','medium','high'])->nullable();
            $table->enum('status', ['todo','in_progress','done'])->default('todo');

            $table->integer('project_id')->unsigned();
            $table->integer('content_id')->unsigned()->nullable();
            $table->integer('created_by')->unsigned()->nullable();

            $table->foreign('project_id')
                  ->references('project_id')->on('projects')
                  ->onDelete('cascade');

            $table->foreign('content_id')
                  ->references('content_id')->on('contents')
                  ->onDelete('set null');

            $table->foreign('created_by')
                  ->references('customer_id')->on('customers')
                  ->onDelete('set null');
        });

        Schema::create('task_assignees', function (Blueprint $table) {
            $table->integer('task_id')->unsigned();
            $table->integer('assignee_id')->unsigned();

            $table->primary(['task_id', 'assignee_id']);

            $table->foreign('task_id')
                  ->references('task_id')->on('tasks')
                  ->onDelete('cascade');

            $table->foreign('assignee_id')
                  ->references('customer_id')->on('customers')
                  ->onDelete('cascade');
        });

        Schema::create('task_contents', function (Blueprint $table) {
            $table->integer('task_id')->unsigned();
            $table->integer('content_id')->unsigned();

            $table->primary(['task_id', 'content_id']);

            $table->foreign('task_id')
                  ->references('task_id')->on('tasks')
                  ->onDelete('cascade');

            $table->foreign('content_id')
                  ->references('content_id')->on('contents')
                  ->onDelete('cascade');
        });
    }

    public function down(): void {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        Schema::dropIfExists('tasks');
        Schema::dropIfExists('task_assignees');
        Schema::dropIfExists('task_contents');

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};
