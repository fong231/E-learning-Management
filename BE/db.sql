-- Drop existing tables if exists (in reverse order of dependencies)
SET FOREIGN_KEY_CHECKS = 0;

-- Get all table names
SET @tables = NULL;
SELECT GROUP_CONCAT('`', table_name, '`') INTO @tables
FROM information_schema.tables
WHERE table_schema = DATABASE();

-- Drop all tables
SET @sql = CONCAT('DROP TABLE IF EXISTS ', @tables);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- USERS & AUTHENTICATION
-- ============================================

-- Customers (Base information)
CREATE TABLE `Customers` (
    `customerID` INT NOT NULL AUTO_INCREMENT,
    `phone_number` VARCHAR(20),
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `avatar` VARCHAR(500),
    `fullname` VARCHAR(255) NOT NULL,
    `role` ENUM('student', 'instructor') NOT NULL,
    PRIMARY KEY (`customerID`)
) ENGINE=InnoDB;

-- Accounts (Login credentials)
CREATE TABLE `Accounts` (
    `customerID` INT NOT NULL,
    `username` VARCHAR(100) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`username`),
    FOREIGN KEY (`customerID`) REFERENCES `Customers`(`customerID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Instructors (Teachers)
CREATE TABLE `Instructors` (
    `instructorID` INT NOT NULL,
    PRIMARY KEY (`instructorID`),
    FOREIGN KEY (`instructorID`) REFERENCES `Customers`(`customerID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Students
CREATE TABLE `Students` (
    `studentID` INT NOT NULL,
    PRIMARY KEY (`studentID`),
    FOREIGN KEY (`studentID`) REFERENCES `Customers`(`customerID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- COURSE STRUCTURE
-- ============================================

-- Semesters
CREATE TABLE `Semesters` (
    `semesterID` INT NOT NULL AUTO_INCREMENT,
    `description` TEXT,
    PRIMARY KEY (`semesterID`)
) ENGINE=InnoDB;

-- Courses
CREATE TABLE `Courses` (
    `courseID` INT NOT NULL AUTO_INCREMENT,
    `number_of_sessions` ENUM('10', '15') NOT NULL,
    `description` TEXT,
    `semesterID` INT,
    `instructorID` INT,
    PRIMARY KEY (`courseID`),
    FOREIGN KEY (`semesterID`) REFERENCES `Semesters`(`semesterID`) ON DELETE SET NULL,
    FOREIGN KEY (`instructorID`) REFERENCES `Instructors`(`instructorID`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Groups (Classes within a course)
CREATE TABLE `Groups` (
    `groupID` INT NOT NULL AUTO_INCREMENT,
    `courseID` INT NOT NULL,
    PRIMARY KEY (`groupID`),
    FOREIGN KEY (`courseID`) REFERENCES `Courses`(`courseID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- COURSE CONTENT
-- ============================================

-- Learning Content (Main content container)
CREATE TABLE `Learning_Content` (
    `contentID` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    PRIMARY KEY (`contentID`)
) ENGINE=InnoDB;

-- Materials (Study materials)
CREATE TABLE `Materials` (
    `materialID` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    PRIMARY KEY (`materialID`),
    FOREIGN KEY (`materialID`) REFERENCES `Learning_Content`(`contentID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Files and Images
CREATE TABLE `Files_Images` (
    `resourceID` INT NOT NULL AUTO_INCREMENT,
    `path` VARCHAR(500) NOT NULL,
    `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `contentID` INT NOT NULL,
    PRIMARY KEY (`resourceID`, `contentID`),
    FOREIGN KEY (`contentID`) REFERENCES `Learning_Content`(`contentID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- RELATIONSHIPS (Junction Tables)
-- ============================================

-- Students join Groups
CREATE TABLE `Student_Group` (
    `studentID` INT NOT NULL,
    `groupID` INT NOT NULL,
    PRIMARY KEY (`studentID`, `groupID`),
    FOREIGN KEY (`studentID`) REFERENCES `Students`(`studentID`) ON DELETE CASCADE,
    FOREIGN KEY (`groupID`) REFERENCES `Groups`(`groupID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Courses join Materials
CREATE TABLE `Course_Materials` (
    `courseID` INT NOT NULL,
    `materialID` INT NOT NULL,
    PRIMARY KEY (`courseID`, `materialID`),
    FOREIGN KEY (`courseID`) REFERENCES `Courses`(`courseID`) ON DELETE CASCADE,
    FOREIGN KEY (`materialID`) REFERENCES `Materials`(`materialID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- ASSIGNMENTS
-- ============================================

-- Assignments
CREATE TABLE `Assignments` (
    `assignmentID` INT NOT NULL AUTO_INCREMENT,
    `start_date` DATETIME,
    `deadline` DATETIME NOT NULL,
    `late_deadline` DATETIME,
    `size_limit` DECIMAL(10, 2), -- in MB
    `file_format` VARCHAR(100),
    `groupID` INT,
    PRIMARY KEY (`assignmentID`),
    FOREIGN KEY (`assignmentID`) REFERENCES `Learning_Content`(`contentID`) ON DELETE CASCADE,
    FOREIGN KEY (`groupID`) REFERENCES `Groups`(`groupID`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================
-- QUIZZES & QUESTIONS
-- ============================================

-- Quizzes
CREATE TABLE `Quizzes` (
    `quizID` INT NOT NULL AUTO_INCREMENT,
    `duration` INT, -- in minutes
    `open_time` DATETIME,
    `close_time` DATETIME,
    `easy_questions` INT DEFAULT 0,
    `medium_questions` INT DEFAULT 0,
    `hard_questions` INT DEFAULT 0,
    `number_of_attempts` INT DEFAULT 1,
    PRIMARY KEY (`quizID`)
) ENGINE=InnoDB;

-- Questions
CREATE TABLE `Questions` (
    `questionID` INT NOT NULL AUTO_INCREMENT,
    `level` ENUM('easy_question', 'medium_question', 'hard_question') NOT NULL,
    `answer` ENUM('A', 'B', 'C', 'D') NOT NULL,
    `quizID` INT,
    PRIMARY KEY (`questionID`),
    FOREIGN KEY (`quizID`) REFERENCES `Quizzes`(`quizID`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Student Scores
CREATE TABLE `Student_Score` (
    `studentID` INT NOT NULL,
    `groupID` INT NOT NULL,
    `quizID` INT NOT NULL,
    `score` DECIMAL(5,2) DEFAULT 0,
    `completed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`studentID`, `groupID`, `quizID`),
    FOREIGN KEY (`quizID`) REFERENCES `Quizzes`(`quizID`) ON DELETE CASCADE,
    FOREIGN KEY (`studentID`, `groupID`) REFERENCES `Student_Group`(`studentID`, `groupID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- ANNOUNCEMENTS
-- ============================================

-- Announcements
CREATE TABLE `Announcements` (
    `announcementID` INT NOT NULL AUTO_INCREMENT,
    `groupID` INT NOT NULL,
    PRIMARY KEY (`announcementID`),
    FOREIGN KEY (`announcementID`) REFERENCES `Learning_Content`(`contentID`) ON DELETE CASCADE,
    FOREIGN KEY (`groupID`) REFERENCES `Groups`(`groupID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- FORUM / DISCUSSION
-- ============================================

-- Topics (Forum topics)
CREATE TABLE `Topics` (
    `topicID` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `courseID` INT NOT NULL,
    PRIMARY KEY (`topicID`),
    FOREIGN KEY (`courseID`) REFERENCES `Courses`(`courseID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Topic Chats (Communication between students)
CREATE TABLE `Topic_Chats` (
    `messageID` INT NOT NULL AUTO_INCREMENT,
    `message` TEXT NOT NULL,
    `topicID` INT NOT NULL,
    `studentID` INT,
    PRIMARY KEY (`messageID`),
    FOREIGN KEY (`topicID`) REFERENCES `Topics`(`topicID`) ON DELETE CASCADE,
    FOREIGN KEY (`studentID`) REFERENCES `Students`(`studentID`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Topic Files (Attachments for topics)
CREATE TABLE `Topic_Files` (
    `fileID` INT NOT NULL AUTO_INCREMENT,
    `path` VARCHAR(500) NOT NULL,
    `topicID` INT NOT NULL,
    PRIMARY KEY (`fileID`),
    FOREIGN KEY (`topicID`) REFERENCES `Topics`(`topicID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Comments (Forum replies - threaded)
CREATE TABLE `Comments` (
    `commentID` INT NOT NULL AUTO_INCREMENT,
    `message` TEXT NOT NULL,
    `ownerID` INT,
    `announcementID` INT NOT NULL,
    PRIMARY KEY (`commentID`),
    FOREIGN KEY (`ownerID`) REFERENCES `Customers`(`customerID`) ON DELETE SET NULL,
    FOREIGN KEY (`announcementID`) REFERENCES `Announcements`(`announcementID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- MESSAGING SYSTEM
-- ============================================

-- Messages (Chat between instructor and students)
CREATE TABLE `Messages` (
    `messageID` INT NOT NULL AUTO_INCREMENT,
    `content` TEXT NOT NULL,
    `senderID` INT NOT NULL,
    `receiverID` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`messageID`),
    FOREIGN KEY (`senderID`) REFERENCES `Customers`(`customerID`) ON DELETE CASCADE,
    FOREIGN KEY (`receiverID`) REFERENCES `Customers`(`customerID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- NOTIFICATIONS (For students only)
-- ============================================

-- Notifications
CREATE TABLE `Notifications` (
    `notificationID` INT NOT NULL AUTO_INCREMENT,
    `type` ENUM('announcement', 'deadline', 'feedback', 'submission', 'message', 'other') NOT NULL,
    `content` TEXT NOT NULL,
    `status` ENUM('read', 'unread') DEFAULT 'unread',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `studentID` INT NOT NULL,
    PRIMARY KEY (`notificationID`),
    FOREIGN KEY (`studentID`) REFERENCES `Students`(`studentID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- TRIGGERS
-- ============================================

DELIMITER $$
CREATE TRIGGER check_message_only_between_instructor_and_student
BEFORE INSERT ON `Messages`
FOR EACH ROW
BEGIN
    IF (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.senderID) = 'instructor' AND (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.receiverID) = 'student'
        OR (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.senderID) = 'student' AND (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.receiverID) = 'instructor' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Messages can only be sent between instructors and students.';
    END IF;
END$$

CREATE TRIGGER check_student_in_multiple_groups_not_in_same_course
BEFORE INSERT ON `Student_Group`
FOR EACH ROW
BEGIN
    DECLARE courseID INT;
    SET courseID = (SELECT `courseID` FROM `Groups` WHERE `groupID` = NEW.groupID);
    IF (SELECT COUNT(*) FROM `Student_Group` WHERE `studentID` = NEW.studentID AND `groupID` IN (SELECT `groupID` FROM `Groups` WHERE `courseID` = courseID)) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student cannot be assigned to multiple groups within the same course.';
    END IF;
END$$
DELIMITER ;


-- ============================================
-- SAMPLE DATA FOR LEARNING MANAGEMENT SYSTEM
-- ============================================

-- ============================================
-- 1. CUSTOMERS (Base users)
-- ============================================
INSERT INTO `Customers` (`customerID`, `phone_number`, `email`, `avatar`, `fullname`, `role`) VALUES
(1, '0901234567', 'john.doe@university.edu', 'avatars/john.jpg', 'John Doe', 'student'),
(2, '0902345678', 'jane.smith@university.edu', 'avatars/jane.jpg', 'Jane Smith', 'student'),
(3, '0903456789', 'bob.wilson@university.edu', 'avatars/bob.jpg', 'Bob Wilson', 'student'),
(4, '0904567890', 'alice.brown@university.edu', 'avatars/alice.jpg', 'Alice Brown', 'student'),
(5, '0905678901', 'charlie.davis@university.edu', 'avatars/charlie.jpg', 'Charlie Davis', 'student'),
(6, '0906789012', 'emma.johnson@university.edu', 'avatars/emma.jpg', 'Emma Johnson', 'student'),
(7, '0907890123', 'david.miller@university.edu', 'avatars/david.jpg', 'David Miller', 'student'),
(8, '0908901234', 'sophia.garcia@university.edu', 'avatars/sophia.jpg', 'Sophia Garcia', 'student'),
-- Instructors
(101, '0911111111', 'dr.robert.brown@university.edu', 'avatars/robert.jpg', 'Dr. Robert Brown', 'instructor'),
(102, '0922222222', 'dr.sarah.jones@university.edu', 'avatars/sarah.jpg', 'Dr. Sarah Jones', 'instructor'),
(103, '0933333333', 'prof.michael.lee@university.edu', 'avatars/michael.jpg', 'Prof. Michael Lee', 'instructor');

-- ============================================
-- 2. ACCOUNTS (Login credentials)
-- ============================================
INSERT INTO `Accounts` (`customerID`, `username`, `password`) VALUES
(1, 'john_doe', '$2y$10$abcdefghijklmnopqrstuvwxyz123456'),  -- password: john123
(2, 'jane_smith', '$2y$10$bcdefghijklmnopqrstuvwxyz234567'),
(3, 'bob_wilson', '$2y$10$cdefghijklmnopqrstuvwxyz345678'),
(4, 'alice_brown', '$2y$10$defghijklmnopqrstuvwxyz456789'),
(5, 'charlie_davis', '$2y$10$efghijklmnopqrstuvwxyz567890'),
(6, 'emma_johnson', '$2y$10$fghijklmnopqrstuvwxyz678901'),
(7, 'david_miller', '$2y$10$ghijklmnopqrstuvwxyz789012'),
(8, 'sophia_garcia', '$2y$10$hijklmnopqrstuvwxyz890123'),
(101, 'dr_robert', '$2y$10$ijklmnopqrstuvwxyz901234'),
(102, 'dr_sarah', '$2y$10$jklmnopqrstuvwxyz012345'),
(103, 'prof_michael', '$2y$10$klmnopqrstuvwxyz123456');

-- ============================================
-- 3. INSTRUCTORS & STUDENTS
-- ============================================
INSERT INTO `Instructors` (`instructorID`) VALUES
(101),
(102),
(103);

INSERT INTO `Students` (`studentID`) VALUES
(1), (2), (3), (4), (5), (6), (7), (8);

-- ============================================
-- 4. SEMESTERS
-- ============================================
INSERT INTO `Semesters` (`semesterID`, `description`) VALUES
(1, 'Fall Semester 2024 - September to December'),
(2, 'Spring Semester 2025 - January to May'),
(3, 'Summer Semester 2025 - June to August');

-- ============================================
-- 5. COURSES
-- ============================================
INSERT INTO `Courses` (`courseID`, `number_of_sessions`, `description`, `semesterID`, `instructorID`) VALUES
(1, '15', 'Introduction to Programming with Java - Learn fundamental programming concepts', 1, 101),
(2, '15', 'Data Structures and Algorithms - Master essential data structures', 1, 101),
(3, '10', 'Web Development Fundamentals - HTML, CSS, JavaScript basics', 1, 102),
(4, '15', 'Database Design and SQL - Learn relational database design', 2, 102),
(5, '10', 'Mobile App Development - Build Android apps with Flutter', 2, 103);

-- ============================================
-- 6. GROUPS
-- ============================================
INSERT INTO `Groups` (`groupID`, `courseID`) VALUES
(1, 1),  -- Java Programming - Group 1
(2, 1),  -- Java Programming - Group 2
(3, 2),  -- Data Structures - Group 1
(4, 3),  -- Web Development - Group 1
(5, 4),  -- Database Design - Group 1
(6, 5);  -- Mobile Development - Group 1

-- ============================================
-- 7. STUDENT_GROUP (Enrollments)
-- ============================================
INSERT INTO `Student_Group` (`studentID`, `groupID`) VALUES
-- Group 1 (Java - Group 1)
(1, 1), (2, 1), (3, 1), (4, 1),
-- Group 2 (Java - Group 2)
(5, 2), (6, 2), (7, 2), (8, 2),
-- Group 3 (Data Structures)
(1, 3), (2, 3), (5, 3), (6, 3),
-- Group 4 (Web Development)
(3, 4), (4, 4), (7, 4), (8, 4),
-- Group 5 (Database Design)
(1, 5), (3, 5), (5, 5), (7, 5),
-- Group 6 (Mobile Development)
(2, 6), (4, 6), (6, 6), (8, 6);

-- ============================================
-- 8. LEARNING CONTENT
-- ============================================
INSERT INTO `Learning_Content` (`contentID`, `title`, `description`) VALUES
-- Course 1: Java Programming
(1, 'Week 1: Introduction to Java', 'Getting started with Java programming environment'),
(2, 'Week 2: Variables and Data Types', 'Understanding primitive and reference types'),
(3, 'Week 3: Control Structures', 'If statements, loops, and switch cases'),
(4, 'Assignment 1: Hello World Application', 'Create your first Java application'),
(5, 'Quiz 1: Java Basics', 'Test your understanding of Java fundamentals'),

-- Course 2: Data Structures
(6, 'Week 1: Arrays and Lists', 'Understanding linear data structures'),
(7, 'Week 2: Stacks and Queues', 'LIFO and FIFO data structures'),
(8, 'Assignment 2: Implement Stack', 'Build a stack data structure from scratch'),

-- Course 3: Web Development
(9, 'Week 1: HTML Basics', 'Introduction to HTML tags and structure'),
(10, 'Week 2: CSS Styling', 'Style your web pages with CSS'),
(11, 'Quiz 2: HTML & CSS Fundamentals', 'Test your web development knowledge'),

-- Announcements
(12, 'Welcome to Java Programming!', 'Important information about the course'),
(13, 'Midterm Exam Schedule', 'Exam will be held on November 15th'),
(14, 'Assignment Deadline Extended', 'Assignment 1 deadline extended to next week');

-- ============================================
-- 9. MATERIALS
-- ============================================
INSERT INTO `Materials` (`materialID`, `title`, `description`) VALUES
(1, 'Java Programming Lecture Slides', 'Comprehensive slides covering Java basics'),
(2, 'Java Installation Guide', 'Step-by-step guide to install JDK'),
(3, 'Data Structures Textbook', 'Recommended reading for the course'),
(6, 'Array Operations Examples', 'Code examples for array manipulations'),
(7, 'Stack Implementation Guide', 'Detailed guide on implementing stacks'),
(9, 'HTML Cheat Sheet', 'Quick reference for HTML tags'),
(10, 'CSS Properties Reference', 'Complete CSS properties guide');

-- ============================================
-- 10. COURSE_MATERIALS
-- ============================================
INSERT INTO `Course_Materials` (`courseID`, `materialID`) VALUES
(1, 1), (1, 2),
(2, 3), (2, 6), (2, 7),
(3, 9), (3, 10);

-- ============================================
-- 11. FILES_IMAGES
-- ============================================
INSERT INTO `Files_Images` (`resourceID`, `path`, `contentID`, `uploaded_at`) VALUES
(1, 'materials/java_week1_slides.pdf', 1, '2024-09-01 10:00:00'),
(2, 'materials/java_week1_code.zip', 1, '2024-09-01 10:05:00'),
(3, 'materials/java_week2_slides.pdf', 2, '2024-09-08 10:00:00'),
(4, 'materials/variables_examples.java', 2, '2024-09-08 10:10:00'),
(5, 'materials/control_structures.pdf', 3, '2024-09-15 10:00:00'),
(6, 'materials/arrays_lecture.pdf', 6, '2024-09-01 09:00:00'),
(7, 'materials/stack_queue_slides.pdf', 7, '2024-09-08 09:00:00'),
(8, 'materials/html_tutorial.pdf', 9, '2024-09-01 11:00:00'),
(9, 'materials/css_examples.zip', 10, '2024-09-08 11:00:00');

-- ============================================
-- 12. ASSIGNMENTS
-- ============================================
INSERT INTO `Assignments` (`assignmentID`, `start_date`, `deadline`, `late_deadline`, `size_limit`, `file_format`, `groupID`) VALUES
(4, '2024-09-20 00:00:00', '2024-09-27 23:59:59', '2024-09-29 23:59:59', 5.00, '.java,.zip', 1),
(8, '2024-10-01 00:00:00', '2024-10-08 23:59:59', '2024-10-10 23:59:59', 10.00, '.java,.zip', 3);

-- ============================================
-- 13. QUIZZES
-- ============================================
INSERT INTO `Quizzes` (`quizID`, `duration`, `open_time`, `close_time`, `easy_questions`, `medium_questions`, `hard_questions`, `number_of_attempts`) VALUES
(5, 30, '2024-10-05 09:00:00', '2024-10-05 18:00:00', 5, 3, 2, 2),
(11, 45, '2024-10-12 09:00:00', '2024-10-12 18:00:00', 6, 4, 0, 1);

-- ============================================
-- 14. QUESTIONS
-- ============================================
INSERT INTO `Questions` (`questionID`, `level`, `answer`, `quizID`) VALUES
-- Quiz 1 (Java Basics) - Easy Questions
(1, 'easy_question', 'A', 5),
(2, 'easy_question', 'B', 5),
(3, 'easy_question', 'C', 5),
(4, 'easy_question', 'D', 5),
(5, 'easy_question', 'A', 5),
-- Quiz 1 - Medium Questions
(6, 'medium_question', 'B', 5),
(7, 'medium_question', 'C', 5),
(8, 'medium_question', 'A', 5),
-- Quiz 1 - Hard Questions
(9, 'hard_question', 'D', 5),
(10, 'hard_question', 'B', 5),

-- Quiz 2 (HTML & CSS) - Easy Questions
(11, 'easy_question', 'A', 11),
(12, 'easy_question', 'C', 11),
(13, 'easy_question', 'B', 11),
(14, 'easy_question', 'D', 11),
(15, 'easy_question', 'A', 11),
(16, 'easy_question', 'B', 11),
-- Quiz 2 - Medium Questions
(17, 'medium_question', 'C', 11),
(18, 'medium_question', 'A', 11),
(19, 'medium_question', 'D', 11),
(20, 'medium_question', 'B', 11);

-- ============================================
-- 15. STUDENT_SCORE
-- ============================================
INSERT INTO `Student_Score` (`studentID`, `groupID`, `quizID`, `score`, `completed_at`) VALUES
-- Quiz 1 scores
(1, 1, 5, 85.50, '2024-10-05 10:30:00'),
(2, 1, 5, 92.00, '2024-10-05 11:00:00'),
(3, 1, 5, 78.50, '2024-10-05 09:45:00'),
(4, 1, 5, 88.00, '2024-10-05 12:00:00'),
(5, 2, 5, 95.00, '2024-10-05 10:00:00'),
(6, 2, 5, 82.50, '2024-10-05 11:30:00'),
(7, 2, 5, 76.00, '2024-10-05 13:00:00'),
(8, 2, 5, 90.50, '2024-10-05 14:00:00'),

-- Quiz 2 scores
(3, 4, 11, 87.00, '2024-10-12 10:00:00'),
(4, 4, 11, 91.50, '2024-10-12 11:00:00'),
(7, 4, 11, 83.00, '2024-10-12 12:00:00'),
(8, 4, 11, 89.00, '2024-10-12 13:00:00');

-- ============================================
-- 16. ANNOUNCEMENTS
-- ============================================
INSERT INTO `Announcements` (`announcementID`, `groupID`) VALUES
(12, 1),
(13, 1),
(14, 2);

-- ============================================
-- 17. TOPICS (Forum)
-- ============================================
INSERT INTO `Topics` (`topicID`, `title`, `description`, `created_at`, `courseID`) VALUES
(1, 'How to install Java JDK?', 'I am having trouble installing Java on my computer. Can someone help?', '2024-09-02 14:30:00', 1),
(2, 'Difference between Array and ArrayList', 'What are the main differences between these two?', '2024-09-10 16:00:00', 1),
(3, 'Best practices for naming variables', 'What are the conventions for naming variables in Java?', '2024-09-15 10:00:00', 1),
(4, 'Stack vs Queue - Real world examples', 'Can someone provide real-world examples of when to use each?', '2024-09-05 11:00:00', 2),
(5, 'HTML5 new features', 'What are the new features introduced in HTML5?', '2024-09-03 13:00:00', 3),
(6, 'CSS Grid vs Flexbox', 'When should I use Grid and when should I use Flexbox?', '2024-09-12 15:00:00', 3);

-- ============================================
-- 18. TOPIC_CHATS
-- ============================================
INSERT INTO `Topic_Chats` (`messageID`, `message`, `topicID`, `studentID`) VALUES
-- Topic 1 discussion
(1, 'Make sure you download the correct version for your operating system', 1, 2),
(2, 'Also, don''t forget to set JAVA_HOME environment variable', 1, 5),
(3, 'Thanks! It worked after setting the environment variable', 1, 1),

-- Topic 2 discussion
(4, 'Array has fixed size, ArrayList is dynamic', 2, 3),
(5, 'ArrayList is slower but more flexible', 2, 6),
(6, 'Use Array when you know the exact size beforehand', 2, 4),

-- Topic 3 discussion
(7, 'Use camelCase for variable names in Java', 3, 7),
(8, 'Start with lowercase letter, be descriptive', 3, 2),

-- Topic 4 discussion
(9, 'Stack is used in function call stack, undo operations', 4, 1),
(10, 'Queue is used in print job queues, breadth-first search', 4, 2),
(11, 'Browser back button is a good example of stack', 4, 5),

-- Topic 5 discussion
(12, 'HTML5 added semantic elements like <header>, <nav>, <footer>', 5, 3),
(13, 'Also added <canvas> for graphics and <video> for media', 5, 4),

-- Topic 6 discussion
(14, 'Use Flexbox for one-dimensional layouts', 6, 7),
(15, 'Use Grid for two-dimensional layouts', 6, 8);

-- ============================================
-- 19. TOPIC_FILES
-- ============================================
INSERT INTO `Topic_Files` (`fileID`, `path`, `topicID`) VALUES
(1, 'forum/java_installation_guide.pdf', 1),
(2, 'forum/array_vs_arraylist_comparison.png', 2),
(3, 'forum/naming_conventions_chart.jpg', 3),
(4, 'forum/stack_queue_examples.pdf', 4),
(5, 'forum/html5_features_list.pdf', 5),
(6, 'forum/grid_vs_flexbox_diagram.png', 6);

-- ============================================
-- 20. COMMENTS (On Announcements)
-- ============================================
INSERT INTO `Comments` (`commentID`, `message`, `ownerID`, `announcementID`) VALUES
(1, 'Thank you for the warm welcome! Excited to start learning Java.', 1, 12),
(2, 'Looking forward to this course!', 2, 12),
(3, 'Will the exam be online or in-person?', 3, 13),
(4, 'What topics will be covered in the midterm?', 4, 13),
(5, 'Thank you for the extension!', 5, 14),
(6, 'This is very helpful, I needed more time.', 6, 14);

-- ============================================
-- 21. MESSAGES (Direct messaging)
-- ============================================
INSERT INTO `Messages` (`messageID`, `content`, `senderID`, `receiverID`, `created_at`) VALUES
-- Student to Instructor
(1, 'Hello Dr. Brown, I have a question about Assignment 1', 1, 101, '2024-09-22 14:00:00'),
(2, 'Hi John, sure! What''s your question?', 101, 1, '2024-09-22 14:05:00'),
(3, 'I''m not sure how to implement the main method', 1, 101, '2024-09-22 14:10:00'),
(4, 'Check the lecture slides from Week 1, there''s an example', 101, 1, '2024-09-22 14:15:00'),

-- Student to Student
(5, 'Hey Jane, did you finish the assignment?', 2, 3, '2024-09-25 20:00:00'),
(6, 'Not yet, working on it now. Want to study together?', 3, 2, '2024-09-25 20:05:00'),
(7, 'Sure! Let''s meet in the library tomorrow', 2, 3, '2024-09-25 20:10:00'),

-- More instructor messages
(8, 'Dr. Sarah, when will you post the quiz results?', 3, 102, '2024-10-06 10:00:00'),
(9, 'Results will be posted by end of day today', 102, 3, '2024-10-06 10:30:00'),

(10, 'Professor Lee, can I submit my project one day late?', 4, 103, '2024-10-15 16:00:00'),
(11, 'Yes, but there will be a 10% penalty', 103, 4, '2024-10-15 16:30:00');

-- ============================================
-- 22. NOTIFICATIONS
-- ============================================
INSERT INTO `Notifications` (`notificationID`, `type`, `content`, `status`, `created_at`, `studentID`) VALUES
-- Announcements
(1, 'announcement', 'New announcement posted: "Welcome to Java Programming!"', 'read', '2024-09-01 08:00:00', 1),
(2, 'announcement', 'New announcement posted: "Welcome to Java Programming!"', 'read', '2024-09-01 08:00:00', 2),
(3, 'announcement', 'New announcement posted: "Welcome to Java Programming!"', 'unread', '2024-09-01 08:00:00', 3),

-- Deadlines
(4, 'deadline', 'Assignment "Hello World Application" is due in 2 days', 'unread', '2024-09-25 09:00:00', 1),
(5, 'deadline', 'Assignment "Hello World Application" is due in 2 days', 'unread', '2024-09-25 09:00:00', 2),
(6, 'deadline', 'Quiz "Java Basics" opens tomorrow at 9:00 AM', 'read', '2024-10-04 10:00:00', 1),

-- Submissions
(7, 'submission', 'Your assignment "Hello World Application" was submitted successfully', 'read', '2024-09-26 15:30:00', 1),
(8, 'submission', 'Your quiz "Java Basics" was submitted. Score: 85.5/100', 'read', '2024-10-05 10:35:00', 1),

-- Feedback
(9, 'feedback', 'Your instructor has provided feedback on Assignment 1', 'unread', '2024-09-30 14:00:00', 1),
(10, 'feedback', 'Your quiz has been graded. Check your score!', 'read', '2024-10-05 17:00:00', 2),

-- Messages
(11, 'message', 'You have a new message from Dr. Robert Brown', 'read', '2024-09-22 14:05:00', 1),
(12, 'message', 'You have a new message from Jane Smith', 'unread', '2024-09-25 20:05:00', 2),

-- Other
(13, 'other', 'New material added to Week 3: Control Structures', 'unread', '2024-09-15 11:00:00', 1),
(14, 'other', 'Course schedule updated. Check your dashboard.', 'unread', '2024-09-16 09:00:00', 5);

-- ============================================
-- END OF SCRIPT
-- ============================================