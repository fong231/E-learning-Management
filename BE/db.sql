-- Drop existing tables if exists (in reverse order of dependencies)
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Customers`;
DROP TABLE IF EXISTS `Instructors`;
DROP TABLE IF EXISTS `Students`;

DROP TABLE IF EXISTS `Semesters`;
DROP TABLE IF EXISTS `Courses`;
DROP TABLE IF EXISTS `Groups`;

DROP TABLE IF EXISTS `Learning_Content`;
DROP TABLE IF EXISTS `Materials`;
DROP TABLE IF EXISTS `Files_Images`;

DROP TABLE IF EXISTS `Student_Group`;
DROP TABLE IF EXISTS `Course_Materials`;

DROP TABLE IF EXISTS `Assignments`;

DROP TABLE IF EXISTS `Quizzes`;
DROP TABLE IF EXISTS `Questions`;
DROP TABLE IF EXISTS `Student_Score`;

DROP TABLE IF EXISTS `Announcements`;

DROP TABLE IF EXISTS `Topics`;
DROP TABLE IF EXISTS `Topic_Chats`;
DROP TABLE IF EXISTS `Topic_Files`;
DROP TABLE IF EXISTS `Comments`;

DROP TABLE IF EXISTS `Messages`;

DROP TABLE IF EXISTS `Notifications`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- USERS & AUTHENTICATION
-- ============================================

-- Customers (Base information)
CREATE TABLE `Customers` (
    `customerID` INT NOT NULL AUTO_INCREMENT,
    `phone_number` VARCHAR(20),
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `avatar` VARCHAR(255),
    `fullname` VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('student', 'instructor') NOT NULL,
    PRIMARY KEY (`customerID`)
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
    `course_name` VARCHAR(255) NOT NULL,
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
    `id` INT NOT NULL, -- "Group 1, 2, 3 for each courses"
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
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
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
    IF (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.senderID) = 'instructor' AND (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.receiverID) = 'instructor'
        OR (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.senderID) = 'student' AND (SELECT `role` FROM `Customers` WHERE `customerID` = NEW.receiverID) = 'student' THEN
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
-- CUSTOMERS (Base users)
-- ============================================
INSERT INTO `Customers` (`customerID`, `phone_number`, `email`, `avatar`, `fullname`, `password`, `role`) VALUES
-- MAIN DEMO STUDENT: John Doe (ID=1)
(1, '0901234567', 'john.doe@university.edu', 'https://ui-avatars.com/api/?name=John+Doe&background=4285F4&color=fff', 'John Doe', '$2b$12$Cb1GHq4oYxRAZFmtJJRKKu3bIne/JlSZGPq6gwoILEwfvsFjEcLd6', 'student'),

-- Other students (supporting cast)
(2, '0902345678', 'jane.smith@university.edu', 'https://ui-avatars.com/api/?name=Jane+Smith&background=EA4335&color=fff', 'Jane Smith', '$2b$12$Cb1GHq4oYxRAZFmtJJRKKu3bIne/JlSZGPq6gwoILEwfvsFjEcLd6', 'student'),
(3, '0903456789', 'bob.wilson@university.edu', 'https://ui-avatars.com/api/?name=Bob+Wilson&background=FBBC04&color=fff', 'Bob Wilson', '$2b$12$Cb1GHq4oYxRAZFmtJJRKKu3bIne/JlSZGPq6gwoILEwfvsFjEcLd6', 'student'),
(4, '0904567890', 'alice.brown@university.edu', 'https://ui-avatars.com/api/?name=Alice+Brown&background=34A853&color=fff', 'Alice Brown', '$2b$12$Cb1GHq4oYxRAZFmtJJRKKu3bIne/JlSZGPq6gwoILEwfvsFjEcLd6', 'student'),
(5, '0905678901', 'charlie.davis@university.edu', 'https://ui-avatars.com/api/?name=Charlie+Davis&background=9C27B0&color=fff', 'Charlie Davis', '$2b$12$Cb1GHq4oYxRAZFmtJJRKKu3bIne/JlSZGPq6gwoILEwfvsFjEcLd6', 'student'),

-- MAIN DEMO INSTRUCTOR: Admin (ID=101)
(101, '0911111111', 'admin@gmail.com', 'https://ui-avatars.com/api/?name=Admin&background=FF5722&color=fff', 'admin', '$2b$12$yGIqw4/uaAsIVa4n/6j5ouz4Ekq6LHXhmP8RJTH5nkq8bVAFsYGny', 'instructor');

-- ============================================
-- 2. INSTRUCTORS & STUDENTS
-- ============================================
INSERT INTO `Instructors` (`instructorID`) VALUES (101);

INSERT INTO `Students` (`studentID`) VALUES (1), (2), (3), (4), (5);

-- ============================================
-- 3. SEMESTER
-- ============================================
INSERT INTO `Semesters` (`semesterID`, `description`) VALUES
(1, 'Semester 1 - Academic Year 2024-2025');

-- ============================================
-- 4. MAIN DEMO COURSE
-- ============================================
INSERT INTO `Courses` (`courseID`, `number_of_sessions`, `course_name`, `description`, `semesterID`, `instructorID`) VALUES
(1, '15', 'Cross-Platform Mobile Application Development', 'Learn Flutter and build mobile apps for Android, iOS, and Web', 1, 101);

-- ============================================
-- 5. GROUPS
-- ============================================
INSERT INTO `Groups` (`groupID`, `id`, `courseID`) VALUES
(1, 1, 1),  -- Group 1 of Course 1
(2, 2, 1);  -- Group 2 of Course 1

-- ============================================
-- 6. STUDENT ENROLLMENTS
-- ============================================
-- John Doe in Group 1 (MAIN DEMO)
INSERT INTO `Student_Group` (`studentID`, `groupID`) VALUES
(1, 1),  -- John Doe -> Group 1
(2, 1),  -- Jane Smith -> Group 1
(3, 1),  -- Bob Wilson -> Group 1
(4, 2),  -- Alice Brown -> Group 2
(5, 2);  -- Charlie Davis -> Group 2

-- ============================================
-- 7. LEARNING CONTENT (Base for all content types)
-- ============================================
INSERT INTO `Learning_Content` (`contentID`, `title`, `description`) VALUES
-- Announcements
(1, 'Welcome to Cross-Platform Development!', 'Welcome everyone! This course will teach you Flutter development.'),
(2, 'Midterm Exam Schedule', 'The midterm exam will be held on December 15, 2024.'),
(3, 'Assignment 1 Deadline Extended', 'Due to popular request, Assignment 1 deadline is extended by 2 days.'),

-- Assignments
(4, 'Assignment 1: Flutter UI Basics', 'Create a simple Flutter app with Material Design widgets.'),
(5, 'Assignment 2: State Management', 'Implement a counter app using Provider for state management.'),
(6, 'Assignment 3: API Integration', 'Build an app that fetches data from REST API and displays it.'),

-- Materials
(7, 'Week 1: Introduction to Flutter', 'Getting started with Flutter framework and Dart programming.'),
(8, 'Week 2: Widgets and Layouts', 'Understanding StatelessWidget, StatefulWidget, and layout widgets.'),
(9, 'Week 3: Navigation and Routing', 'Learn how to navigate between screens in Flutter.'),
(10, 'Week 4: State Management with Provider', 'Deep dive into Provider package for state management.'),

-- Quizzes (as Learning Content)
(11, 'Quiz 1: Flutter Basics', 'Test your knowledge on Flutter fundamentals.'),
(12, 'Quiz 2: Widgets and State', 'Quiz about Flutter widgets and state management.');

-- ============================================
-- 8. ANNOUNCEMENTS
-- ============================================
INSERT INTO `Announcements` (`announcementID`, `groupID`) VALUES
(1, 1),  -- Welcome announcement for Group 1
(2, 1),  -- Midterm schedule for Group 1
(3, 2);  -- Deadline extension for Group 2

-- ============================================
-- 9. COMMENTS ON ANNOUNCEMENTS
-- ============================================
INSERT INTO `Comments` (`commentID`, `message`, `ownerID`, `announcementID`) VALUES
(1, 'Thank you professor! Looking forward to this course.', 1, 1),  -- John Doe comment
(2, 'Will the midterm be online or in-person?', 1, 2),  -- John Doe question
(3, 'The exam will be conducted online via our LMS platform.', 101, 2),  -- Admin reply
(4, 'Thanks for the extension!', 2, 3);  -- Jane Smith

-- ============================================
-- 10. ASSIGNMENTS
-- ============================================
INSERT INTO `Assignments` (`assignmentID`, `title`, `description`, `start_date`, `deadline`, `late_deadline`, `size_limit`, `file_format`, `groupID`) VALUES
(4, 'Assignment 1: Flutter UI Basics', 'Create a simple Flutter app with Material Design widgets. Include AppBar, ListView, and Cards.', '2024-11-01 00:00:00', '2024-11-15 23:59:59', '2024-11-17 23:59:59', 10.00, '.zip,.dart', 1),
(5, 'Assignment 2: State Management', 'Implement a counter app using Provider. Show increment, decrement, and reset functionality.', '2024-11-16 00:00:00', '2024-11-30 23:59:59', '2024-12-02 23:59:59', 10.00, '.zip,.dart', 1),
(6, 'Assignment 3: API Integration', 'Build an app that fetches data from JSONPlaceholder API and displays posts in a list.', '2024-12-01 00:00:00', '2024-12-15 23:59:59', NULL, 15.00, '.zip,.dart', 1);

-- ============================================
-- 11. MATERIALS
-- ============================================
INSERT INTO `Materials` (`materialID`, `title`, `description`) VALUES
(7, 'Week 1: Introduction to Flutter', 'Lecture slides covering Flutter installation, project structure, and first app.'),
(8, 'Week 2: Widgets and Layouts', 'Comprehensive guide on Flutter widgets - Container, Row, Column, Stack, etc.'),
(9, 'Week 3: Navigation and Routing', 'Learn Navigator, Routes, and passing data between screens.'),
(10, 'Week 4: State Management with Provider', 'Deep dive into Provider package with examples and best practices.');

-- ============================================
-- 12. COURSE_MATERIALS (Link materials to course)
-- ============================================
INSERT INTO `Course_Materials` (`courseID`, `materialID`) VALUES
(1, 7),
(1, 8),
(1, 9),
(1, 10);

-- ============================================
-- 13. FILES FOR CONTENT
-- ============================================
INSERT INTO `Files_Images` (`resourceID`, `path`, `contentID`, `uploaded_at`) VALUES
-- Announcement 1 files
(1, 'https://example.com/files/course_syllabus.pdf', 1, '2024-11-01 08:00:00'),
(2, 'https://example.com/files/welcome_guide.pdf', 1, '2024-11-01 08:00:00'),

-- Assignment 1 files (instructor's reference)
(3, 'https://example.com/files/assignment1_requirements.pdf', 4, '2024-11-01 09:00:00'),
(4, 'https://example.com/files/ui_examples.png', 4, '2024-11-01 09:00:00'),

-- Material 1 files
(5, 'https://example.com/materials/week1_slides.pdf', 7, '2024-11-01 10:00:00'),
(6, 'https://example.com/materials/flutter_installation_guide.pdf', 7, '2024-11-01 10:00:00'),

-- Material 2 files
(7, 'https://example.com/materials/week2_widgets_demo.zip', 8, '2024-11-08 10:00:00'),
(8, 'https://example.com/materials/widget_catalog.pdf', 8, '2024-11-08 10:00:00');

-- ============================================
-- 14. QUIZZES
-- ============================================
INSERT INTO `Quizzes` (`quizID`, `duration`, `open_time`, `close_time`, `easy_questions`, `medium_questions`, `hard_questions`, `number_of_attempts`) VALUES
(11, 30, '2024-11-20 09:00:00', '2024-11-20 18:00:00', 5, 3, 2, 2),
(12, 45, '2024-12-05 09:00:00', '2024-12-05 18:00:00', 6, 4, 3, 1);

-- ============================================
-- 15. QUESTIONS FOR QUIZZES
-- ============================================
-- Quiz 1: Flutter Basics (10 questions)
INSERT INTO `Questions` (`questionID`, `level`, `answer`, `quizID`) VALUES
-- Easy Questions
(1, 'easy_question', 'A', 11),  -- What is Flutter?
(2, 'easy_question', 'B', 11),  -- Which language is Flutter based on?
(3, 'easy_question', 'C', 11),  -- What is a StatelessWidget?
(4, 'easy_question', 'D', 11),  -- What does hot reload do?
(5, 'easy_question', 'A', 11),  -- What is Material Design?

-- Medium Questions
(6, 'medium_question', 'B', 11),  -- Difference between StatelessWidget and StatefulWidget
(7, 'medium_question', 'C', 11),  -- What is BuildContext?
(8, 'medium_question', 'A', 11),  -- How to pass data between screens?

-- Hard Questions
(9, 'hard_question', 'D', 11),  -- Explain widget lifecycle
(10, 'hard_question', 'B', 11); -- What is InheritedWidget?

-- Quiz 2: Widgets and State (13 questions)
INSERT INTO `Questions` (`questionID`, `level`, `answer`, `quizID`) VALUES
-- Easy Questions
(11, 'easy_question', 'A', 12),
(12, 'easy_question', 'C', 12),
(13, 'easy_question', 'B', 12),
(14, 'easy_question', 'D', 12),
(15, 'easy_question', 'A', 12),
(16, 'easy_question', 'B', 12),

-- Medium Questions
(17, 'medium_question', 'C', 12),
(18, 'medium_question', 'A', 12),
(19, 'medium_question', 'D', 12),
(20, 'medium_question', 'B', 12),

-- Hard Questions
(21, 'hard_question', 'C', 12),
(22, 'hard_question', 'A', 12),
(23, 'hard_question', 'D', 12);

-- ============================================
-- 16. STUDENT SCORES (John Doe's quiz results)
-- ============================================
INSERT INTO `Student_Score` (`studentID`, `groupID`, `quizID`, `score`, `completed_at`) VALUES
(1, 1, 11, 85.50, '2024-11-20 10:30:00'),  -- John Doe scored 85.5% on Quiz 1
(2, 1, 11, 92.00, '2024-11-20 11:00:00'),  -- Jane Smith
(3, 1, 11, 78.00, '2024-11-20 12:00:00');  -- Bob Wilson

-- ============================================
-- 17. FORUM TOPICS
-- ============================================
INSERT INTO `Topics` (`topicID`, `title`, `description`, `created_at`, `courseID`) VALUES
(1, 'How to fix "flutter doctor" errors?', 'I am getting errors when running flutter doctor. Android SDK not found.', '2024-11-02 14:30:00', 1),
(2, 'Best state management approach?', 'What is the recommended state management solution for beginners? Provider, Bloc, or Riverpod?', '2024-11-10 16:00:00', 1),
(3, 'Assignment 1 - AppBar not showing', 'My AppBar widget is not displaying. Here is my code...', '2024-11-12 10:00:00', 1),
(4, 'Recommended resources for Flutter', 'Can anyone share good tutorials or documentation links?', '2024-11-15 13:00:00', 1);

-- ============================================
-- 18. TOPIC CHATS (Replies)
-- ============================================
INSERT INTO `Topic_Chats` (`messageID`, `message`, `topicID`, `studentID`) VALUES
-- Topic 1 discussion
(1, 'You need to download Android Studio and set ANDROID_HOME environment variable.', 2, 1),
(2, 'Also run "flutter doctor --android-licenses" to accept licenses.', 3, 1),
(3, 'Thanks! That fixed it.', 1, 1),

-- Topic 2 discussion
(4, 'For beginners, I recommend starting with Provider. It is simple and officially supported.', 2, 2),
(5, 'Provider is great for small to medium apps. For complex apps, consider Bloc.', 3, 2),
(6, 'Thank you! I will start with Provider then.', 1, 2),

-- Topic 3 discussion
(7, 'Make sure you are using Scaffold widget and passing AppBar to its appBar property.', 2, 3),
(8, 'Oh I forgot to wrap my widget with Scaffold! Thanks!', 1, 3),

-- Topic 4 discussion
(9, 'Check out flutter.dev official documentation. Also, "Flutter in Action" book is excellent.', 3, 4),
(10, 'YouTube channel "The Net Ninja" has great Flutter tutorials for free.', 2, 4);

-- ============================================
-- 19. TOPIC FILES
-- ============================================
INSERT INTO `Topic_Files` (`fileID`, `path`, `topicID`) VALUES
(1, 'https://example.com/forum/flutter_doctor_screenshot.png', 1),
(2, 'https://example.com/forum/appbar_code.dart', 3),
(3, 'https://example.com/forum/resource_list.pdf', 4);

-- ============================================
-- 20. MESSAGES (Private chat between John Doe and Admin)
-- ============================================
INSERT INTO `Messages` (`messageID`, `content`, `senderID`, `receiverID`, `created_at`) VALUES
-- John Doe asks about Assignment 1
(1, 'Hello Professor, I have a question about Assignment 1. Can I use external packages?', 1, 101, '2024-11-05 14:00:00'),
(2, 'Hi John! Yes, you can use any packages from pub.dev, but make sure to document them in your README.', 101, 1, '2024-11-05 14:15:00'),
(3, 'Thank you! Also, should the UI match the exact design in the requirements?', 1, 101, '2024-11-05 14:20:00'),
(4, 'The design should be similar, but you can add your own creative touch. Focus on functionality first.', 101, 1, '2024-11-05 14:30:00'),

-- John Doe asks about Quiz 1
(5, 'Professor, I missed Quiz 1 due to illness. Can I take it again?', 1, 101, '2024-11-21 10:00:00'),
(6, 'Sorry to hear that. Yes, I will open a makeup quiz for you tomorrow. Please bring medical certificate.', 101, 1, '2024-11-21 10:30:00'),
(7, 'Thank you so much! I will bring the certificate.', 1, 101, '2024-11-21 10:35:00'),

-- Jane asks about project
(8, 'Hi Professor, can we work in pairs for the final project?', 2, 101, '2024-11-25 15:00:00'),
(9, 'Yes, you can work in pairs. Please submit a team registration form by next week.', 101, 2, '2024-11-25 15:30:00');

-- ============================================
-- 21. NOTIFICATIONS (For John Doe)
-- ============================================
INSERT INTO `Notifications` (`notificationID`, `type`, `content`, `status`, `created_at`, `studentID`) VALUES
-- Announcements
(1, 'announcement', 'New announcement: "Welcome to Cross-Platform Development!"', 'read', '2024-11-01 08:00:00', 1),
(2, 'announcement', 'New announcement: "Midterm Exam Schedule"', 'read', '2024-11-10 09:00:00', 1),

-- Deadlines
(3, 'deadline', 'Assignment "Flutter UI Basics" is due in 2 days (Nov 15, 2024)', 'unread', '2024-11-13 09:00:00', 1),
(4, 'deadline', 'Quiz "Flutter Basics" opens tomorrow at 9:00 AM', 'read', '2024-11-19 10:00:00', 1),

-- Submissions
(5, 'submission', 'Your assignment "Flutter UI Basics" was submitted successfully', 'read', '2024-11-14 20:30:00', 1),
(6, 'submission', 'Your quiz "Flutter Basics" was submitted. Score: 85.5/100', 'read', '2024-11-20 10:35:00', 1),

-- Feedback
(7, 'feedback', 'Your instructor has graded Assignment 1. Score: 90/100', 'unread', '2024-11-18 16:00:00', 1),

-- Messages
(8, 'message', 'You have a new message from admin', 'read', '2024-11-05 14:15:00', 1),
(9, 'message', 'You have a new message from admin', 'unread', '2024-11-21 10:30:00', 1),

-- Other
(10, 'other', 'New material added: "Week 4: State Management with Provider"', 'unread', '2024-11-22 11:00:00', 1);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- SUMMARY OF DEMO DATA
-- ============================================
-- MAIN DEMO USERS:
--   Student: John Doe (ID=1) - john.doe@university.edu - password: admin
--   Instructor: admin (ID=101) - admin@gmail.com - password: admin
--
-- MAIN DEMO COURSE:
--   Cross-Platform Mobile Application Development (ID=1)
--   - Group 1: John Doe, Jane Smith, Bob Wilson
--   - Group 2: Alice Brown, Charlie Davis
--
-- DEMO CONTENT:
--   - 3 Announcements (with comments)
--   - 3 Assignments (Assignment 1, 2, 3)
--   - 4 Materials (Week 1-4)
--   - 2 Quizzes (23 questions total)
--   - 4 Forum Topics (with replies)
--   - 9 Private Messages (John ↔ Admin)
--   - 10 Notifications (for John)
--
-- DEMO SCENARIO:
-- John Doe has:
--   ✓ Enrolled in Course 1, Group 1
--   ✓ Viewed announcements and commented
--   ✓ Submitted Assignment 1 (graded: 90/100)
--   ✓ Completed Quiz 1 (score: 85.5/100)
--   ✓ Participated in forum discussions
--   ✓ Messaged with instructor
--   ✓ Received various notifications
--   ✓ Has pending Assignment 2 & 3
--   ✓ Has upcoming Quiz 2
--
-- This data is perfect for demo video showing:
-- 1. Student dashboard with progress
-- 2. View announcements and materials
-- 3. Submit assignments
-- 4. Take quizzes
-- 5. Forum participation
-- 6. Private messaging with instructor
-- 7. Notifications system
-- ============================================