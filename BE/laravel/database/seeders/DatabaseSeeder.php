<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Tắt kiểm tra khóa ngoại để chèn dữ liệu dễ dàng hơn
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Xóa dữ liệu cũ
        DB::table('chat_privates')->truncate();
        DB::table('chat_rooms')->truncate();
        DB::table('task_assignees')->truncate();
        DB::table('tasks')->truncate();
        DB::table('task_contents')->truncate();
        DB::table('project_members')->truncate();
        DB::table('projects')->truncate();
        DB::table('resources')->truncate();
        DB::table('contents')->truncate();
        DB::table('customers')->truncate();

        // --- CUSTOMERS ---
        DB::table('customers')->insert([
            ['customer_id' => 1, 'full_name' => 'Trần Văn An', 'email' => 'an.tran@app.com', 'password' => Hash::make('123456'), 'nickname' => 'An_Dev'],
            ['customer_id' => 2, 'full_name' => 'Lê Thị Bình', 'email' => 'binh.le@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Binh_PM'],
            ['customer_id' => 3, 'full_name' => 'Nguyễn Văn Cảnh', 'email' => 'canh.nguyen@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Canh_Design'],
            ['customer_id' => 4, 'full_name' => 'Phạm Văn Duy', 'email' => 'duy.pham@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Duy_Frontend'],
            ['customer_id' => 5, 'full_name' => 'Trần Văn Đức', 'email' => 'duc.tran@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Duc_Backend'],
            ['customer_id' => 6, 'full_name' => 'Võ Thị Giang', 'email' => 'giang.vo@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Giang_Marketing'],
            ['customer_id' => 7, 'full_name' => 'Trần Văn Hải', 'email' => 'hai.tran@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Hai_Sales'],
            ['customer_id' => 8, 'full_name' => 'Nguyễn Văn Hồng', 'email' => 'hong.nguyen@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Hong_IT'],
            ['customer_id' => 9, 'full_name' => 'Lê Thị Kim', 'email' => 'kim.le@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Kim_HR'],
            ['customer_id' => 10, 'full_name' => 'Phạm Văn Long', 'email' => 'long.pham@app.com', 'password' => Hash::make('123456'), 'nickname' => 'Long_Admin'],
        ]);

        // --- PROJECTS ---
        DB::table('projects')->insert([
            ['project_id' => 1, 'name' => 'Dự án Phát triển App V1', 'description' => 'Phát triển các tính năng cốt lõi cho phiên bản 1.', 'owner_id' => 1],
            ['project_id' => 2, 'name' => 'Chiến dịch Marketing Q4', 'description' => 'Tập trung vào quảng bá sản phẩm mới.', 'owner_id' => 2],
        ]);

        // --- PROJECT MEMBERS ---
        DB::table('project_members')->insert([
            ['project_id' => 1, 'member_id' => 2, 'role' => 'manager'],
            ['project_id' => 1, 'member_id' => 3, 'role' => 'member'],
            ['project_id' => 1, 'member_id' => 4, 'role' => 'member'],
            ['project_id' => 1, 'member_id' => 5, 'role' => 'member'],
            ['project_id' => 2, 'member_id' => 1, 'role' => 'member'],
            ['project_id' => 2, 'member_id' => 6, 'role' => 'member'],
        ]);

        // --- CONTENTS --- (Dùng cho Task, ChatRoom, ChatPrivate)
        DB::table('contents')->insert([
            ['content_id' => 1, 'type' => 'task'],        // Task 1: Content cho đính kèm file
            ['content_id' => 2, 'type' => 'chat_room'],   // ChatRoom: Content cho tin nhắn có file
            ['content_id' => 3, 'type' => 'chat_private'],// ChatPrivate: Content cho tin nhắn có file
        ]);

        // --- TASKS ---
        DB::table('tasks')->insert([
            ['task_id' => 1, 'title' => 'Thiết kế giao diện dashboard', 'created_by' => 2, 'due_date' => Carbon::now()->addDays(7), 'priority' => 'high', 'status' => 'in_progress', 'project_id' => 1, 'content_id' => 1],
            ['task_id' => 2, 'title' => 'Viết API xác thực người dùng', 'created_by' => 1, 'due_date' => Carbon::now()->addDays(3), 'priority' => 'medium', 'status' => 'todo', 'project_id' => 1, 'content_id' => NULL],
        ]);
        
        // --- TASK ASSIGNEES ---
        DB::table('task_assignees')->insert([
            ['task_id' => 1, 'assignee_id' => 3], // Task 1 giao cho Cảnh
            ['task_id' => 2, 'assignee_id' => 1], // Task 2 giao cho An
        ]);

        // --- TASK RESOURCES ---
        DB::table('task_contents')->insert([
            ['task_id' => 1, 'content_id' => 1], // Task 1 có file đính kèm
        ]);

        // --- CHAT ROOMS ---
        DB::table('chat_rooms')->insert([
            ['message_id' => 1, 'message' => 'Chào mọi người, đây là tài liệu yêu cầu mới nhất.', 'project_id' => 1, 'sender_id' => 2, 'content_id' => 2, 'is_important' => 1],
            ['message_id' => 2, 'message' => 'Đã nhận, tôi sẽ bắt đầu thiết kế.', 'project_id' => 1, 'sender_id' => 3, 'content_id' => NULL, 'is_important' => 0],
        ]);

        // --- CHAT PRIVATES ---
        DB::table('chat_privates')->insert([
            ['message_id' => 1, 'message' => '', 'project_id' => 1, 'sender_id' => 3, 'receiver_id' => 1, 'content_id' => 3, 'is_read' => 0],
            ['message_id' => 2, 'message' => 'Bạn kiểm tra lại bản nháp thiết kế này nhé.', 'project_id' => 1, 'sender_id' => 3, 'receiver_id' => 1, 'content_id' => NULL, 'is_read' => 0],
            ['message_id' => 3, 'message' => 'Ok, tôi sẽ xem ngay.', 'project_id' => 1, 'sender_id' => 1, 'receiver_id' => 3, 'content_id' => NULL, 'is_read' => 0],
        ]);

        // --- RESOURCES ---
        DB::table('resources')->insert([
            ['resource_id' => 1, 'type' => 'file', 'size' => 1200000, 'file_name' => 'dashboard_design.fig', 'uploaded_by' => 3, 'content_id' => 1], // Cho Task 1
            ['resource_id' => 2, 'type' => 'file', 'size' => 500000, 'file_name' => 'Requirements_V1.pdf', 'uploaded_by' => 2, 'content_id' => 2], // Cho ChatRoom 401
            ['resource_id' => 3, 'type' => 'image', 'size' => 250000, 'file_name' => 'logo_draft.png', 'uploaded_by' => 3, 'content_id' => 3], // Cho ChatPrivate 601
        ]);

        // --- NOTIFICATIONS ---

        // Bật lại kiểm tra khóa ngoại
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
}
