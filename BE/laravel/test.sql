-- Tệp SQL này được tạo tự động từ các tệp Migration của Laravel.
-- Nó tạo ra cấu trúc cơ sở dữ liệu cho toàn bộ ứng dụng.

-- Tắt kiểm tra khóa ngoại để cho phép DROP và CREATE TABLE không theo thứ tự
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa tất cả các bảng nếu chúng đã tồn tại để thiết lập lại môi trường sạch
-- (Xóa theo thứ tự đảo ngược của Khóa ngoại để tránh lỗi)
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `task_resources`;
DROP TABLE IF EXISTS `task_assignees`;
DROP TABLE IF EXISTS `tasks`;
DROP TABLE IF EXISTS `chat_rooms`;
DROP TABLE IF EXISTS `chat_privates`;
DROP TABLE IF EXISTS `project_members`;
DROP TABLE IF EXISTS `projects`;
DROP TABLE IF EXISTS `resources`;
DROP TABLE IF EXISTS `contents`;
DROP TABLE IF EXISTS `customers`;

-- ******************************************************
-- 1. BẢNG 'customers' (Người dùng)
-- ******************************************************
CREATE TABLE `customers` (
    `customer_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) UNIQUE NOT NULL, -- Thêm UNIQUE cho email (nên có)
    `password` VARCHAR(255) NOT NULL,
    `avatar` VARCHAR(255) NULL,
    `nickname` VARCHAR(255) NULL,
    
    `email_verified_at` TIMESTAMP NULL,
    `verification_token` VARCHAR(64) NULL,
    `verification_token_expires_at` TIMESTAMP NULL,
    `reset_token` VARCHAR(64) NULL,
    `reset_token_expires_at` TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 2. BẢNG 'contents' (Nội dung dùng chung cho file, chat, task)
-- ******************************************************
CREATE TABLE `contents` (
    `content_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `type` ENUM('chat_private', 'chat_room', 'task') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 3. BẢNG 'resources' (Tài nguyên/File đính kèm)
-- ******************************************************
CREATE TABLE `resources` (
    `resource_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `path` VARCHAR(255) NULL,
    `type` ENUM('file', 'image') NOT NULL,
    `size` INT NOT NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    `uploaded_by` INT UNSIGNED NULL, -- Khóa ngoại tới customers
    `content_id` INT UNSIGNED NOT NULL, -- Khóa ngoại tới contents

    -- Khóa ngoại: uploaded_by
    CONSTRAINT `resources_uploaded_by_foreign`
        FOREIGN KEY (`uploaded_by`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE SET NULL,

    -- Khóa ngoại: content_id
    CONSTRAINT `resources_content_id_foreign`
        FOREIGN KEY (`content_id`)
        REFERENCES `contents` (`content_id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 4. BẢNG 'projects' (Dự án)
-- ******************************************************
CREATE TABLE `projects` (
    `project_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    `owner_id` INT UNSIGNED NOT NULL, -- Khóa ngoại tới customers (chủ sở hữu)

    -- Khóa ngoại: owner_id
    CONSTRAINT `projects_owner_id_foreign`
        FOREIGN KEY (`owner_id`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 5. BẢNG 'project_members' (Thành viên dự án)
-- ******************************************************
CREATE TABLE `project_members` (
    `project_id` INT UNSIGNED NOT NULL,
    `member_id` INT UNSIGNED NOT NULL,
    `role` ENUM('manager', 'member') DEFAULT 'member' NOT NULL,

    -- Khóa chính kép
    PRIMARY KEY (`project_id`, `member_id`),

    -- Khóa ngoại: project_id
    CONSTRAINT `project_members_project_id_foreign`
        FOREIGN KEY (`project_id`)
        REFERENCES `projects` (`project_id`)
        ON DELETE CASCADE,

    -- Khóa ngoại: member_id
    CONSTRAINT `project_members_member_id_foreign`
        FOREIGN KEY (`member_id`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 6. BẢNG 'tasks' (Công việc)
-- ******************************************************
CREATE TABLE `tasks` (
    `task_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `title` TEXT NOT NULL,
    `description` TEXT NULL, -- Thêm từ migration tasks
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `due_date` TIMESTAMP NULL,
    `priority` ENUM('low', 'medium', 'high') NULL,
    `status` ENUM('todo', 'in_progress', 'done') DEFAULT 'todo' NOT NULL,

    `project_id` INT UNSIGNED NOT NULL,
    `content_id` INT UNSIGNED NULL, -- Liên kết tới bình luận/nội dung
    `created_by` INT UNSIGNED NULL,

    -- Khóa ngoại: project_id
    CONSTRAINT `tasks_project_id_foreign`
        FOREIGN KEY (`project_id`)
        REFERENCES `projects` (`project_id`)
        ON DELETE CASCADE,

    -- Khóa ngoại: content_id
    CONSTRAINT `tasks_content_id_foreign`
        FOREIGN KEY (`content_id`)
        REFERENCES `contents` (`content_id`)
        ON DELETE SET NULL,

    -- Khóa ngoại: created_by
    CONSTRAINT `tasks_created_by_foreign`
        FOREIGN KEY (`created_by`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 7. BẢNG 'task_assignees' (Người được giao việc)
-- ******************************************************
CREATE TABLE `task_assignees` (
    `task_id` INT UNSIGNED NOT NULL,
    `assignee_id` INT UNSIGNED NOT NULL,

    -- Khóa chính kép
    PRIMARY KEY (`task_id`, `assignee_id`),

    -- Khóa ngoại: task_id
    CONSTRAINT `task_assignees_task_id_foreign`
        FOREIGN KEY (`task_id`)
        REFERENCES `tasks` (`task_id`)
        ON DELETE CASCADE,

    -- Khóa ngoại: assignee_id
    CONSTRAINT `task_assignees_assignee_id_foreign`
        FOREIGN KEY (`assignee_id`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 8. BẢNG 'task_resources' (Tài nguyên đính kèm cho Task)
-- ******************************************************
CREATE TABLE `task_resources` (
    `task_id` INT UNSIGNED NOT NULL,
    `resource_id` INT UNSIGNED NOT NULL,

    -- Khóa chính kép
    PRIMARY KEY (`task_id`, `resource_id`),

    -- Khóa ngoại: task_id
    CONSTRAINT `task_resources_task_id_foreign`
        FOREIGN KEY (`task_id`)
        REFERENCES `tasks` (`task_id`)
        ON DELETE CASCADE,

    -- Khóa ngoại: resource_id
    CONSTRAINT `task_resources_resource_id_foreign`
        FOREIGN KEY (`resource_id`)
        REFERENCES `resources` (`resource_id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 9. BẢNG 'chat_rooms' (Tin nhắn phòng chat dự án)
-- ******************************************************
CREATE TABLE `chat_rooms` (
    `message_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `is_important` BOOLEAN DEFAULT 0 NOT NULL, -- Dùng cho chức năng pin message

    `project_id` INT UNSIGNED NOT NULL,
    `sender_id` INT UNSIGNED NULL,
    `content_id` INT UNSIGNED NULL, -- Liên kết tới nội dung đính kèm

    -- Khóa ngoại: project_id
    CONSTRAINT `chat_rooms_project_id_foreign`
        FOREIGN KEY (`project_id`)
        REFERENCES `projects` (`project_id`)
        ON DELETE CASCADE,

    -- Khóa ngoại: sender_id
    CONSTRAINT `chat_rooms_sender_id_foreign`
        FOREIGN KEY (`sender_id`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE SET NULL,

    -- Khóa ngoại: content_id
    CONSTRAINT `chat_rooms_content_id_foreign`
        FOREIGN KEY (`content_id`)
        REFERENCES `contents` (`content_id`)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ******************************************************
-- 10. BẢNG 'chat_privates' (Tin nhắn riêng tư 1:1)
-- ******************************************************
CREATE TABLE `chat_privates` (
    `message_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `is_read` BOOLEAN DEFAULT 0 NOT NULL,
    `is_important` BOOLEAN DEFAULT 0 NOT NULL, -- Dùng cho chức năng pin message

    `project_id` INT UNSIGNED NOT NULL, -- Giả định tin nhắn 1:1 vẫn nằm trong phạm vi Project
    `sender_id` INT UNSIGNED NULL,
    `receiver_id` INT UNSIGNED NULL,
    `content_id` INT UNSIGNED NULL,

    -- Khóa ngoại: project_id
    CONSTRAINT `chat_privates_project_id_foreign`
        FOREIGN KEY (`project_id`)
        REFERENCES `projects` (`project_id`)
        ON DELETE CASCADE,
            
    -- Khóa ngoại: sender_id
    CONSTRAINT `chat_privates_sender_id_foreign`
        FOREIGN KEY (`sender_id`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE SET NULL,
            
    -- Khóa ngoại: receiver_id
    CONSTRAINT `chat_privates_receiver_id_foreign`
        FOREIGN KEY (`receiver_id`)
        REFERENCES `customers` (`customer_id`)
        ON DELETE SET NULL,        

    -- Khóa ngoại: content_id
    CONSTRAINT `chat_privates_content_id_foreign`
        FOREIGN KEY (`content_id`)
        REFERENCES `contents` (`content_id`)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ******************************************************
-- 11. BẢNG 'notifications' (Thông báo)
-- ******************************************************
CREATE TABLE `notifications` (
    -- Laravel UUID được ánh xạ thành CHAR(36) trong MySQL
    `id` CHAR(36) PRIMARY KEY, 
    `content` VARCHAR(255) NOT NULL,
    `type` VARCHAR(255) NOT NULL,
    
    -- Ánh xạ $table->morphs('notifiable')
    `notifiable_type` VARCHAR(255) NOT NULL,
    `notifiable_id` BIGINT UNSIGNED NOT NULL,
    
    `data` TEXT NOT NULL,
    `read_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    
    KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`, `notifiable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bật lại kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;