# E-Learning LMS – Backend API Specification (Expected by Flutter FE)

Base URL (in FE `AppConstants.baseUrl`):

```text
http://10.0.2.2:80
```

All endpoints below are **relative** to this base URL.

The FE uses a shared `ApiService` with:

- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer <token>` (if logged in)

The FE usually expects JSON responses with either:

- A top-level object: `{ "<resource>": { ... } }`, **or**
- `{ "data": { ... } }` for single objects
- `{ "<resource_plural>": [ ... ] }` **or** `{ "data": [ ... ] }` for lists

The models show accepted key names; the backend can send extra fields – FE will ignore unknown keys.

---

## 1. Authentication

### 1.1 POST `/auth/login`

**Request body**

```json
{
  "email": "student1@university.edu",
  "password": "string"
}
```

**Success response (200)**

```json
{
  "token": "JWT_OR_SESSION_TOKEN",
  "user": {
    "id": 1,                 // or user_id
    "fullname": "John Doe",
    "email": "student1@university.edu",
    "avatar": "https://.../avatar.png",      // optional
    "phone_number": "0901234567",            // optional
    "address": "string or null",            // optional
    "role": "student" | "instructor",
    "created_at": "2024-09-01T10:00:00Z",
    "updated_at": "2024-09-10T12:00:00Z"     // optional
  }
}
```

### 1.2 POST `/auth/register`

Used for creating new users (most likely students).

**Request body** (minimal expected):

```json
{
  "fullname": "John Doe",
  "email": "student1@university.edu",
  "password": "string",
  "phone_number": "0901234567",    // optional
  "address": "string",            // optional
  "role": "student"               // or "instructor" (if allowed)
}
```

**Success response (200)** – same structure as `/auth/login`:

```json
{
  "token": "...",
  "user": { /* see above User fields */ }
}
```

---

## 2. User Profile

The FE derives `user_id` and `role` from saved user data, then calls profile-related endpoints.

### 2.1 GET `/users/{id}/profile` (optional)

_Not directly used in code, but updateProfile assumes similar structure._

**Response**

```json
{
  "user": {
    "id": 1,
    "fullname": "John Doe",
    "email": "student1@university.edu",
    "avatar": "avatars/john.jpg",
    "phone_number": "0901234567",
    "address": "some address",
    "role": "student",
    "created_at": "2024-09-01T10:00:00Z",
    "updated_at": "2024-09-10T12:00:00Z"
  }
}
```

### 2.2 PUT `/users/{id}/profile`

Used by `AuthRepository.updateProfile`.

**Request body** (any subset of fields):

```json
{
  "fullname": "New Name",
  "phone_number": "0901111111",
  "address": "New Address",
  "avatar": "https://.../avatar.png"
}
```

**Success response**

```json
{
  "user": { /* same User fields as login */ }
}
```

### 2.3 POST `/users/{id}/change-password`

Used by `AuthRepository.changePassword`.

**Request body**

```json
{
  "current_password": "oldPass",
  "new_password": "newPass123"
}
```

**Response (200)**

```json
{
  "message": "Password changed successfully"
}
```

Error codes:

- 400 with `{ "message": "Current password is incorrect" }`

---

## 3. Semesters & Courses

### 3.1 GET `/semesters`

Used by `CourseRepository.getSemesters()` (via `CourseProvider.loadSemesters`).

**Response**

```json
{
  "semesters": [
    {
      "semester_id": 1,
      "description": "Fall Semester 2024"
    },
    {
      "semester_id": 2,
      "description": "Spring Semester 2025"
    }
  ]
}
```

### 3.2 GET `/courses`

Used by `CourseRepository.getCourses()`.

**Query params (optional)**

- `semester_id`: filter by semester
- `instructor_id`: filter by instructor
- `student_id`: filter by student (alternative to specific routes)

**Response**

```json
{
  "courses": [
    {
      "course_id": 1,
      "course_name": "Introduction to Programming", // Course.description in DB
      "description": "...",
      "instructor_id": 101,
      "instructor_name": "Dr. Brown",
      "semester_id": 1,
      "semester_name": "Fall 2024",
      "number_of_sessions": 15,
      "start_date": "2024-09-01T00:00:00Z",
      "end_date": "2024-12-01T00:00:00Z",
      "created_at": "2024-08-20T10:00:00Z",
      "updated_at": null
    }
  ]
}
```

### 3.3 GET `/students/{studentId}/courses?semester_id={semesterId}`

Used by `CourseRepository.getStudentCoursesWithSemester()` for student dashboard.

**Response** – same as `/courses`, but only courses that the student is enrolled in for that semester.

### 3.4 GET `/instructors/{instructorId}/courses?semester_id={semesterId}`

Used by `CourseRepository.getInstructorCoursesWithSemester()`.

**Response** – same structure as `/courses`.

### 3.5 GET `/courses/{courseId}`

Used by `CourseRepository.getCourseById()`.

**Response**

```json
{
  "course": {
    "course_id": 1,
    "course_name": "...", // Course.description in DB
    "description": "...",
    "instructor_id": 101,
    "instructor_name": "...",
    "semester_id": 1,
    "semester_name": "...",
    "number_of_sessions": 15,
    "start_date": "2024-09-01T00:00:00Z",
    "end_date": "2024-12-01T00:00:00Z",
    "created_at": "...",
    "updated_at": null
  }
}
```

### 3.6 POST `/courses`

Used by `CourseRepository.createCourse()` from `CreateCourseScreen`.

**Request body** (from FE):

```json
{
  "name": "Course Name",          // will be mapped to course_name on BE
  "description": "string or null",
  "semester_id": 1,
  "number_of_sessions": 10,        // or 15
  "start_date": "2024-09-01T00:00:00Z",
  "end_date": "2024-12-01T00:00:00Z"
}
```

Backend should infer `instructor_id` from authenticated user or accept it explicitly.

**Response**

```json
{
  "course": { /* CourseModel fields as above */ }
}
```

### 3.7 PUT `/courses/{courseId}`

Used by `CourseRepository.updateCourse()`.

**Request body** – same shape as POST `/courses`, any subset allowed.

**Response** – `{ "course": { ... } }`.

### 3.8 DELETE `/courses/{courseId}`

Used by `CourseRepository.deleteCourse()`.

**Response**

```json
{
  "message": "Course deleted successfully"
}
```

---

## 4. Groups & Enrollments

### 4.1 GET `/courses/{courseId}/groups`

Used by `CourseRepository.getCourseGroups()`.

**Response**

```json
{
  "groups": [
    {
      "group_id": 1,
      "course_id": 1,
      "course_name": "Introduction to Programming", // Course.description in DB
      "group_name": "Group 1",            // Group.id in DB
      "students": 25,                      // number of students
      "created_at": "2024-09-01T00:00:00Z"
    }
  ]
}
```

### 4.2 POST `/groups/{groupId}/students`

Used by `CourseRepository.enrollStudent()` to enroll a student into a **specific group of a course**.

**Request body**

```json
{
  "student_id": 1
}
```

**Response**

```json
{
  "message": "Student enrolled successfully"
}
```

### 4.3 DELETE `/groups/{groupId}/students/{studentId}`

Used by `CourseRepository.unenrollStudent()` to remove a student from a group.

**Response**

```json
{
  "message": "Student unenrolled successfully"
}
```

> Note: DB has `Student_Group(studentID, groupID)`; backend must enforce the rule **“in one course, a student belongs to at most one group”** (for example by rejecting an enrollment if the student is already in another group for the same course).

---

## 5. Learning Content & Materials (Course Content / Materials Tab)

### 5.1 GET `/courses/{courseId}/content`

Used by `CourseRepository.getCourseContent()`.

**Response**

```json
{
  "content": [
    {
      "content_id": 1,
      "course_id": 1,
      "course_name": "Introduction to Programming", // Course.description in DB
      "title": "Week 1: Introduction",
      "description": "...",
      "content_url": "materials/java_week1_slides.pdf",
      "session_number": 1,
      "created_at": "2024-09-01T10:00:00Z",
      "updated_at": null
    }
  ]
}
```

### 5.2 POST `/courses/{courseId}/content`

Used by `CourseRepository.addCourseContent()`.

**Request body**

```json
{
  "title": "Week 1: Introduction",
  "description": "...",
  "content_url": "materials/file.pdf", // for link/document/video path
  "session_number": 1
}
```

**Response**

```json
{
  "content": { /* single LearningContentModel */ }
}
```

### 5.3 PUT `/content/{contentId}`

Used by `CourseRepository.updateCourseContent()`.

**Request body** – same fields as POST.

**Response**

```json
{
  "content": { /* updated LearningContentModel */ }
}
```

### 5.4 DELETE `/content/{contentId}`

Used by `CourseRepository.deleteCourseContent()`.

**Response**

```json
{
  "message": "Content deleted successfully"
}
```

### 5.5 File upload for materials (assignment upload is separate)

Used by `AssignmentRepository.uploadAssignmentFile()` as pattern; you can reuse for general materials if needed.

#### POST `/uploads/material`

Multipart/form-data upload via `ApiService.uploadFile` (no JSON body):

- Field name: `file`

**Response**

```json
{
  "file_url": "materials/java_week1_slides.pdf"
}
```

---

## 6. Assignments & Submissions

### 6.1 GET `/courses/{courseId}/assignments`

Used by `AssignmentRepository.getCourseAssignments()` for Classwork tab.

**Response**

```json
{
  "assignments": [
    {
      "assignment_id": 4,
      "group_id": 1,
      "title": "Hello World Application",
      "description": "...",
      "deadline": "2024-09-27T23:59:59Z",
      "late_deadline": "2024-09-29T23:59:59Z",
      "size_limit": "5.00",             // MB, optional
      "file_format": ".java,.zip",     // optional
      "created_at": "2024-09-20T00:00:00Z",
      "updated_at": null,
      "files_url": [
        "assignments/4/spec.pdf"
      ]
    }
  ]
}
```

### 6.2 GET `/assignments/{assignmentId}`

Used by `AssignmentRepository.getAssignmentById()`.

**Response**

```json
{
  "assignment": { /* see AssignmentModel fields above */ }
}
```

### 6.3 POST `/assignments`

Used by `AssignmentRepository.createAssignment()` from `CreateAssignmentScreen`.

**Request body** (from FE):

```json
{
  "course_id": 1,
  "title": "Assignment 1",
  "description": "Description...",
  "deadline": "2024-09-27T23:59:59Z",
  "max_score": 100.0,
  "group_id": 1             // recommended to support groups
}
```

Backend should also store `late_deadline`, `size_limit`, `file_format` if needed; FE can ignore extras.

**Response**

```json
{
  "assignment": { /* AssignmentModel */ }
}
```

### 6.4 POST `/uploads/assignment`

Used by both `AssignmentRepository.createAssignment` and `uploadAssignmentFile`.

Multipart upload:

- Field name: `file`

**Response**

```json
{
  "file_url": "assignments/4/requirements.pdf"
}
```

### 6.5 PUT `/assignments/{assignmentId}`

Used by `AssignmentRepository.updateAssignment()`.

**Request body** – any subset of assignment fields.

**Response** – `{ "assignment": { ... } }`.

### 6.6 DELETE `/assignments/{assignmentId}`

Used by `AssignmentRepository.deleteAssignment()`.

**Response**

```json
{
  "message": "Assignment deleted successfully"
}
```

### 6.7 GET `/assignments/{assignmentId}/submissions?student_id={studentId}`

Used by `AssignmentRepository.getStudentSubmissions()`.

**Response**

```json
{
  "submissions": [
    {
      "submission_id": 1,
      "assignment_id": 4,
      "student_id": 1,
      "student_name": "John Doe",
      "submission_text": "My answer...",
      "file_url": "submissions/1/code.zip",
      "submitted_at": "2024-09-26T15:30:00Z",
      "score": 85.5,
      "feedback": "Good work",
      "graded_at": "2024-09-27T10:00:00Z"
    }
  ]
}
```

### 6.8 GET `/assignments/{assignmentId}/submissions`

Used by `AssignmentRepository.getAssignmentSubmissions()` (for instructor view).

**Response** – same shape as above, list of all students.

### 6.9 POST `/submissions`

Used by `AssignmentRepository.submitAssignment()` for student submission.

**Request body**

```json
{
  "assignment_id": 4,
  "student_id": 1,
  "submission_text": "Optional text answer",
  "file_url": "submissions/1/code.zip"   // from upload endpoint
}
```

**Response**

```json
{
  "submission": { /* AssignmentSubmissionModel */ }
}
```

### 6.10 PUT `/submissions/{submissionId}/grade`

Used by `AssignmentRepository.gradeSubmission()`.

**Request body**

```json
{
  "score": 90.0,
  "feedback": "Well done"
}
```

**Response**

```json
{
  "submission": { /* updated AssignmentSubmissionModel */ }
}
```

---

## 7. Quizzes, Questions, and Attempts

### 7.1 GET `/courses/{courseId}/quizzes`

Used by `QuizRepository.getCourseQuizzes()`.

**Response**

```json
{
  "quizzes": [
    {
      "quiz_id": 5,
      "course_id": 1,
      "course_name": "...", // Course.description in DB
      "title": "Quiz 1: Basics",
      "description": "...",
      "duration": 30,
      "number_of_attempts": 2,
      "start_time": "2024-10-05T09:00:00Z",  // optional
      "end_time": "2024-10-05T18:00:00Z",    // optional
      "created_at": "2024-09-25T10:00:00Z",
      "updated_at": null
    }
  ]
}
```

### 7.2 GET `/quizzes/{quizId}`

Used by `QuizRepository.getQuizById()`.

**Response** – `{ "quiz": { ... } }` with fields above.

### 7.3 POST `/quizzes`

Used by `QuizRepository.createQuiz()` from `CreateQuizScreen`.

**Request body**

```json
{
  "course_id": 1,
  "title": "Quiz 1", 
  "description": "Optional",
  "duration": 30,
  "number_of_attempts": 1
}
```

**Response** – `{ "quiz": { ... } }`.

### 7.4 PUT `/quizzes/{quizId}`

Used by `QuizRepository.updateQuiz()`.

**Request body** – subset of quiz fields.

### 7.5 DELETE `/quizzes/{quizId}`

Used by `QuizRepository.deleteQuiz()`.

**Response** – `{ "message": "Quiz deleted successfully" }`.

### 7.6 GET `/quizzes/{quizId}/questions`

Used by `QuizRepository.getQuizQuestions()`.

**Response**

```json
{
  "questions": [
    {
      "question_id": 1,
      "quiz_id": 5,
      "question_text": "What is Java?",
      "question_type": "multiple_choice",        // or true_false, short_answer
      "level": "easy_question",                 // or medium_question, hard_question
      "points": 1,
      "options": ["A", "B", "C", "D"],
      "correct_answer": "A",
      "created_at": "2024-09-25T10:00:00Z"
    }
  ]
}
```

### 7.7 POST `/questions`

Used by `QuizRepository.addQuestion()`.

**Request body**

```json
{
  "quiz_id": 5,
  "question_text": "...",
  "question_type": "multiple_choice",     
  "level": "medium_question",
  "points": 1,
  "options": ["A", "B", "C", "D"],
  "correct_answer": "B"
}
```

**Response** – `{ "question": { ... } }`.

### 7.8 PUT `/questions/{questionId}`

Used by `QuizRepository.updateQuestion()`.

**Request body** – subset of question fields.

### 7.9 DELETE `/questions/{questionId}`

Used by `QuizRepository.deleteQuestion()`.

**Response** – `{ "message": "Question deleted successfully" }`.

### 7.10 POST `/quiz-attempts`

Used by `QuizRepository.startQuizAttempt()` when student starts a quiz.

**Request body**

```json
{
  "quiz_id": 5,
  "student_id": 1
}
```

**Response**

```json
{
  "attempt": {
    "attempt_id": 10,
    "quiz_id": 5,
    "student_id": 1,
    "student_name": "John Doe",
    "started_at": "2024-10-05T09:15:00Z",
    "completed_at": null,
    "score": null,
    "attempt_number": 1
  }
}
```

### 7.11 POST `/quiz-attempts/{attemptId}/submit`

Used by `QuizRepository.submitQuizAttempt()`.

**Request body**

```json
{
  "answers": {
    "1": "A", 
    "2": "B"
  }
}
```

**Response**

```json
{
  "attempt": {
    "attempt_id": 10,
    "quiz_id": 5,
    "student_id": 1,
    "student_name": "John Doe",
    "started_at": "2024-10-05T09:15:00Z",
    "completed_at": "2024-10-05T09:30:00Z",
    "score": 8.0,
    "attempt_number": 1
  }
}
```

### 7.12 GET `/quizzes/{quizId}/attempts?student_id={studentId}`

Used by `QuizRepository.getStudentAttempts()`.

**Response**

```json
{
  "attempts": [ { /* QuizAttemptModel */ } ]
}
```

### 7.13 GET `/quizzes/{quizId}/attempts`

Used by `QuizRepository.getQuizAttempts()` (instructor view).

**Response** – same as above but for all students.

---

## 8. Forum / Discussion (Topics, Chats, Announcements, Comments)

### 8.1 GET `/courses/{courseId}/topics`

Used by `ForumRepository.getCourseTopics()`.

**Response**

```json
{
  "topics": [
    {
      "topic_id": 1,
      "course_id": 1,
      "course_name": "...", // Course.description in DB
      "creator_id": 1,
      "creator_name": "John Doe",
      "creator_role": "student",  
      "title": "How to install JDK?",
      "content": "I have a problem...",
      "view_count": 5,
      "reply_count": 3,
      "created_at": "2024-09-02T14:30:00Z",
      "updated_at": null
    }
  ]
}
```

### 8.2 GET `/topics/{topicId}`

Used by `ForumRepository.getTopicById()`.

**Response** – `{ "topic": { ... } }` with fields above.

### 8.3 POST `/topics`

Used by `ForumRepository.createTopic()`.

**Request body**

```json
{
  "course_id": 1,
  "creator_id": 1,
  "creator_role": "student",         
  "title": "Title",
  "content": "Description body"
}
```

**Response** – `{ "topic": { ... } }`.

### 8.4 PUT `/topics/{topicId}`

Used by `ForumRepository.updateTopic()`.

**Request body** – subset of topic fields.

### 8.5 DELETE `/topics/{topicId}`

Used by `ForumRepository.deleteTopic()`.

**Response** – `{ "message": "Topic deleted successfully" }`.

### 8.6 GET `/topics/{topicId}/chats`

Used by `ForumRepository.getTopicChats()`.

**Response**

```json
{
  "chats": [
    {
      "chat_id": 1,
      "topic_id": 1,
      "user_id": 1,
      "user_name": "John Doe",
      "user_role": "student",
      "message": "Make sure you download the correct version",
      "created_at": "2024-09-02T14:30:00Z"
    }
  ]
}
```

### 8.7 POST `/topic-chats`

Used by `ForumRepository.addTopicChat()`.

**Request body**

```json
{
  "topic_id": 1,
  "user_id": 1,
  "user_role": "student",
  "message": "Reply text"
}
```

**Response** – `{ "chat": { ... } }`.

### 8.8 DELETE `/topic-chats/{chatId}`

Used by `ForumRepository.deleteTopicChat()`.

**Response** – `{ "message": "Chat deleted successfully" }`.

### 8.9 GET `/courses/{courseId}/announcements`

Used by `ForumRepository.getCourseAnnouncements()`.

**Response**

```json
{
  "announcements": [
    {
      "announcement_id": 12,
      "course_id": 1,
      "course_name": "...", // Course.description in DB
      "instructor_id": 101,
      "instructor_name": "Dr. Brown",
      "title": "Welcome to Java Programming!",
      "content": "Important info...",
      "created_at": "2024-09-01T08:00:00Z",
      "updated_at": null
    }
  ]
}
```

### 8.10 GET `/announcements/{announcementId}`

Used by `ForumRepository.getAnnouncementById()`.

**Response** – `{ "announcement": { ... } }`.

### 8.11 POST `/announcements`

Used by `ForumRepository.createAnnouncement()` from `CreateAnnouncementScreen`.

**Request body**

```json
{
  "course_id": 1,
  "instructor_id": 101,          // or inferred from token
  "title": "New Announcement",
  "content": "Body text"
}
```

**Response** – `{ "announcement": { ... } }`.

### 8.12 PUT `/announcements/{announcementId}`

Used by `ForumRepository.updateAnnouncement()`.

**Request body** – subset of announcement fields.

### 8.13 DELETE `/announcements/{announcementId}`

Used by `ForumRepository.deleteAnnouncement()`.

**Response** – `{ "message": "Announcement deleted successfully" }`.

### 8.14 GET `/announcements/{announcementId}/comments`

Used by `ForumRepository.getAnnouncementComments()`.

**Response**

```json
{
  "comments": [
    {
      "comment_id": 1,
      "announcement_id": 12,
      "topic_id": null,
      "user_id": 1,
      "user_name": "John Doe",
      "user_role": "student",
      "content": "Thank you!",
      "created_at": "2024-09-01T09:00:00Z"
    }
  ]
}
```

### 8.15 POST `/comments`

Used by `ForumRepository.addComment()`.

**Request body**

```json
{
  "announcement_id": 12,     // or topic_id instead
  "topic_id": null,
  "user_id": 1,
  "user_role": "student",
  "content": "Comment text"
}
```

**Response** – `{ "comment": { ... } }`.

### 8.16 DELETE `/comments/{commentId}`

Used by `ForumRepository.deleteComment()`.

**Response** – `{ "message": "Comment deleted successfully" }`.

---

## 9. Messaging (Instructor ↔ Student) & Notifications

### 9.1 GET `/users/{userId}/messages`

Used by `MessageRepository.getUserMessages()` to list direct messages.

**Response**

```json
{
  "messages": [
    {
      "message_id": 1,
      "sender_id": 1,
      "sender_name": "Student A",
      "sender_role": "student",
      "receiver_id": 101,
      "receiver_name": "Dr. Brown",
      "receiver_role": "instructor",
      "content": "Hello, I have a question",
      "is_read": false,
      "sent_at": "2024-09-22T14:00:00Z"
    }
  ]
}
```

### 9.2 GET `/messages/conversation/{userId1}/{userId2}`

Used by `MessageRepository.getConversation()`.

**Response** – `{ "messages": [ MessageModel... ] }` (sorted by `sent_at`).

### 9.3 POST `/messages`

Used by `MessageRepository.sendMessage()`.

**Request body**

```json
{
  "sender_id": 1,
  "receiver_id": 101,
  "content": "Question about assignment",
  "sender_role": "student",
  "receiver_role": "instructor"
}
```

**Response** – `{ "message": { ... } }`.

_Backend should enforce the rule from SQL trigger: only student↔instructor, not same-role conversations._

### 9.4 PUT `/messages/{messageId}/read`

Used by `MessageRepository.markAsRead()`.

**Request body** – `{}` (no fields required).

**Response** – `{ "message": "Message marked as read" }`.

### 9.5 DELETE `/messages/{messageId}`

Used by `MessageRepository.deleteMessage()`.

**Response** – `{ "message": "Message deleted successfully" }`.

### 9.6 GET `/users/{userId}/messages/unread-count`

Used by `MessageRepository.getUnreadCount()`.

**Response**

```json
{
  "count": 3
}
```

### 9.7 GET `/students/{studentId}/notifications`

Used by `MessageRepository.getNotifications()` for notification list.

**Response**

```json
{
  "notifications": [
    {
      "notification_id": 1,
      "student_id": 1,
      "type": "announcement" | "deadline" | "feedback" | "submission" | "message" | "other",
      "title": "New announcement posted",
      "content": "Welcome to Java Programming!",
      "is_read": false,
      "created_at": "2024-09-01T08:00:00Z"
    }
  ]
}
```

### 9.8 PUT `/notifications/{notificationId}/read`

Used by `MessageRepository.markNotificationAsRead()`.

**Request body** – `{}`.

**Response** – `{ "message": "Notification marked as read" }`.

### 9.9 DELETE `/notifications/{notificationId}`

Used by `MessageRepository.deleteNotification()`.

**Response** – `{ "message": "Notification deleted successfully" }`.

### 9.10 GET `/students/{studentId}/notifications/unread-count`

Used by `MessageRepository.getUnreadNotificationCount()`.

**Response**

```json
{
  "count": 5
}
```

---

## 10. Error Format

`ApiService` handles errors by HTTP status code. Recommended error payloads:

```json
{
  "message": "Human-readable error message"
}
```

HTTP status codes:

- `400` – validation / bad request
- `401` – unauthorized → FE shows “Please login again”
- `403` – forbidden → FE shows “You don't have permission”
- `404` – not found → FE shows generic “Not found”
- `5xx` – server error → FE shows “Server error: Please try again later”

---

## 11. Mapping to Database (`BE/db.sql`)

This API spec is consistent with your existing schema:

- `Customers` ⇔ `UserModel` (plus roles student/instructor)
- `Students`, `Instructors` tables used for role-specific data
- `Semesters`, `Courses`, `Groups`, `Student_Group` for enrollment and scheduling
- `Learning_Content`, `Materials`, `Files_Images` for course content & materials
- `Assignments`, `Quizzes`, `Questions`, `Student_Score` for assessments
- `Announcements`, `Topics`, `Topic_Chats`, `Topic_Files`, `Comments` for forum
- `Messages`, `Notifications` for communication and alerts

Your backend team can freely adjust internal table structure and joins, as long as these **endpoint URLs**, **request body fields**, and **response JSON fields** remain compatible with this document.

---

## 12. Frontend usage summary (screens → providers → repositories → APIs)

This section lists how the current Flutter FE uses the above APIs. It is meant as a quick map for backend changes.

- **Auth / profile**
  - **LoginScreen** → `AuthProvider.login(email, password)` → `AuthRepository.login()` → **POST** `/auth/login`.
  - **RegisterScreen** → `AuthProvider.register(userData)` → `AuthRepository.register()` → **POST** `/auth/register`.
  - **EditProfileScreen** → `AuthProvider.updateProfile(userData)` → `AuthRepository.updateProfile()` → **PUT** `/users/{id}/profile`.
  - **ChangePasswordScreen** → `AuthProvider.changePassword()` → `AuthRepository.changePassword()` → **POST** `/users/{id}/change-password`.

- **Semesters & courses (student)**
  - **StudentCoursesScreen** (tab in `StudentDashboardScreen`)
    - `CourseProvider.loadSemesters()` → `CourseRepository.getSemesters()` → **GET** `/semesters`.
    - `CourseProvider.loadStudentCoursesWithSemester(semesterId)` → `CourseRepository.getStudentCoursesWithSemester()` → **GET** `/students/{studentId}/courses?semester_id={semesterId}`.
  - **StudentAssignmentsScreen** (global pending assignments)
    - Uses `CourseProvider.loadSemesters()` and `CourseProvider.loadStudentCoursesWithSemester()` as above to determine current semester courses.

- **Semesters & courses (instructor)**
  - **InstructorCoursesScreen** (tab in `InstructorDashboardScreen`)
    - `CourseProvider.loadSemesters()` → `CourseRepository.getSemesters()` → **GET** `/semesters`.
    - `CourseProvider.loadInstructorCoursesWithSemester(semesterId)` → `CourseRepository.getInstructorCoursesWithSemester()` → **GET** `/instructors/{instructorId}/courses?semester_id={semesterId}`.
    - Delete course: `CourseProvider.deleteCourse(course.id)` → `CourseRepository.deleteCourse()` → **DELETE** `/courses/{courseId}`.
  - **CreateCourseScreen**
    - Create: `CourseProvider.createCourse(courseData)` → `CourseRepository.createCourse()` → **POST** `/courses`.
    - Edit (when wired) would call `CourseProvider.updateCourse()` → `CourseRepository.updateCourse()` → **PUT** `/courses/{courseId}`.

- **Groups & student-group enrollment (instructor)**
  - **CourseGroupsScreen**
    - Load groups: `CourseProvider.loadCourseGroups(courseId)` → `CourseRepository.getCourseGroups()` → **GET** `/courses/{courseId}/groups`.
    - Create group: `CourseProvider.createGroup(courseId)` → `CourseRepository.createGroup()` → **POST** `/groups`.
  - **InstructorStudentsScreen** (course-specific view)
    - Assign to group: `CourseProvider.enrollStudentToGroup(studentId, groupId)` → `CourseRepository.enrollStudent()` → **POST** `/groups/{groupId}/students`.
    - Remove from group: `CourseProvider.unenrollStudentFromGroup(studentId, groupId)` → `CourseRepository.unenrollStudent()` → **DELETE** `/groups/{groupId}/students/{studentId}`.

- **Course detail (student)**
  - **CourseDetailScreen.OverviewTab**
    - Course data itself is passed in as `CourseModel` from the courses list (which came from `/students/{studentId}/courses`).
    - Announcements list: `_OverviewTab` → `ForumProvider.loadCourseAnnouncements(course.id)` → `ForumRepository.getCourseAnnouncements()` → **GET** `/courses/{courseId}/announcements`.
  - **CourseDetailScreen.MaterialsTab**
    - `_MaterialsTab` → `CourseProvider.loadCourseContent(courseId)` → `CourseRepository.getCourseContent()` → **GET** `/courses/{courseId}/content`.
  - **CourseDetailScreen.AssignmentsTab**
    - `_AssignmentsTab` → `AssignmentProvider.loadCourseAssignments(courseId)` → `AssignmentRepository.getCourseAssignments()` → **GET** `/courses/{courseId}/assignments`.
  - **CourseDetailScreen.QuizzesTab**
    - `_QuizzesTab` → `QuizProvider.loadCourseQuizzes(courseId)` → `QuizRepository.getCourseQuizzes()` → **GET** `/courses/{courseId}/quizzes`.
    - Starting attempts & submitting answers will later use:
      - `QuizProvider.startQuizAttempt()` → `QuizRepository.startQuizAttempt()` → **POST** `/quiz-attempts`.
      - `QuizProvider.submitQuizAttempt()` → `QuizRepository.submitQuizAttempt()` → **POST** `/quiz-attempts/{attemptId}/submit`.
  - **CourseDetailScreen.DiscussionTab**
    - `_DiscussionTab` → `ForumProvider.loadCourseTopics(courseId)` → `ForumRepository.getCourseTopics()` → **GET** `/courses/{courseId}/topics`.

- **Assignments (instructor)**
  - **CreateAssignmentScreen**
    - Create assignment: `AssignmentProvider.createAssignment(data)` → `AssignmentRepository.createAssignment()` → **POST** `/assignments`.
    - (Optional file upload, if hooked up) would use `AssignmentRepository.uploadAssignmentFile()` → **POST** `/uploads/assignment`.

- **Assignments (student)**
  - **StudentAssignmentsScreen** (global pending assignments)
    - Per course: `AssignmentRepository.getCourseAssignments()` → **GET** `/courses/{courseId}/assignments`.
    - Per assignment: `AssignmentRepository.getStudentSubmissions()` → **GET** `/assignments/{assignmentId}/submissions?student_id={studentId}`.
    - The screen keeps only assignments with **no submissions** yet.
  - **StudentSubmitAssignmentScreen**
    - Submit: `AssignmentProvider.submitAssignment(submissionData)` → `AssignmentRepository.submitAssignment()` → **POST** `/submissions`.

- **Quizzes (instructor)**
  - **CreateQuizScreen**
    - Load instructor courses for dropdown: as in InstructorCoursesScreen (`GET /semesters`, `GET /instructors/{instructorId}/courses?semester_id=...`).
    - Create quiz: `QuizProvider.createQuiz(quizData)` → `QuizRepository.createQuiz()` → **POST** `/quizzes`.
    - Create questions: `QuizProvider.addQuestion(questionData)` → `QuizRepository.addQuestion()` → **POST** `/questions`.

- **Forum / group discussion (student)**
  - **StudentForumScreen** (global forum tab)
    - Determines current semester courses via `CourseProvider.loadSemesters()` and `CourseProvider.loadStudentCoursesWithSemester()` as in the courses tab.
    - Loads topics for all enrolled courses: `ForumProvider.loadTopicsForCourses(courseIds)` → `ForumRepository.getCourseTopics()` → **GET** `/courses/{courseId}/topics` (per course).
  - **StudentTopicChatScreen** (topic chat / group discussion)
    - Load messages: `ForumProvider.loadTopicChats(topic.id)` → `ForumRepository.getTopicChats()` → **GET** `/topics/{topicId}/chats`.
    - Send message: `ForumProvider.addTopicChat(chatData)` → `ForumRepository.addTopicChat()` → **POST** `/topic-chats`.

- **Announcements (instructor)**
  - **CreateAnnouncementScreen** (intended wiring)
    - Would use `ForumProvider.createAnnouncement(announcementData)` → `ForumRepository.createAnnouncement()` → **POST** `/announcements`.
    - Courses for the dropdown should come from the same instructor-course APIs as `InstructorCoursesScreen`.

- **Messaging & notifications (student)**
  - **StudentMessagesScreen**
    - List messages: `MessageProvider.loadUserMessages(userId)` → `MessageRepository.getUserMessages()` → **GET** `/users/{userId}/messages`.
    - Unread counts: `MessageProvider.refreshUnreadCounts(...)` → `MessageRepository.getUnreadCount()` → **GET** `/users/{userId}/messages/unread-count`.
  - **StudentChatScreen** (1–1 conversation)
    - Conversation: `MessageProvider.loadConversation(userId, otherUserId)` → `MessageRepository.getConversation()` → **GET** `/messages/conversation/{userId1}/{userId2}`.
    - Send: `MessageProvider.sendMessage(messageData)` → `MessageRepository.sendMessage()` → **POST** `/messages`.
    - Mark as read: `MessageProvider.markMessageAsRead(messageId)` → `MessageRepository.markAsRead()` → **PUT** `/messages/{messageId}/read`.
  - **StudentNotificationsScreen**
    - List: `MessageRepository.getNotifications()` → **GET** `/students/{studentId}/notifications`.
    - Mark read: `MessageRepository.markNotificationAsRead()` → **PUT** `/notifications/{notificationId}/read`.
    - Delete: `MessageRepository.deleteNotification()` → **DELETE** `/notifications/{notificationId}`.
    - Unread badge: `MessageRepository.getUnreadNotificationCount()` → **GET** `/students/{studentId}/notifications/unread-count`.

This mapping should make it straightforward to see which FE screens depend on which endpoints when evolving the backend.
