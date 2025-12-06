# PHÂN TÍCH CHI TIẾT FINAL PROJECT - E-LEARNING APP

## I. TỔNG QUAN DỰ ÁN

### 🎯 Mục tiêu
- Xây dựng ứng dụng E-learning cross-platform bằng Flutter
- Giao diện lấy cảm hứng từ Google Classroom
- Hỗ trợ 2 vai trò: **Instructor** (admin/admin) và **Student** (nhiều users)

### ⚠️ LƯU Ý QUAN TRỌNG (Sai là 0 điểm)
1. **Nội dung học thuật**: CHỈ về Công nghệ thông tin (lập trình, database, AI)
2. **Vai trò**: CHỈ có 2 roles (Instructor & Student), KHÔNG được thêm role khác
3. **Instructor account**: Bắt buộc là `admin/admin` (fixed)
4. **Deployment bắt buộc**: APK (arm64) + Windows EXE/macOS + Web public
5. **Database yêu cầu**: Online DB + Offline DB (SQLite/Hive)

---

## II. PHÂN TÍCH CHI TIẾT TỪNG CHỨC NĂNG

### 📱 1. INTERFACE & UX (3 layers)

#### **Layer 1: Homepage với Role-Based Context**

**🎓 Student Homepage:**
- Hiển thị danh sách các khóa học đã enroll dạng **cards**
- Mỗi card bao gồm:
  - Cover image (hình ảnh khóa học)
  - Course name (tên khóa học)
  - Instructor name (tên giảng viên)
  - Các thông tin liên quan khác

**👨‍🏫 Instructor Dashboard:**
- Tổng quan metrics học kỳ hiện tại:
  - Số lượng courses
  - Số lượng groups
  - Số lượng students
  - Số lượng assignments
  - Số lượng quizzes
  - Progress charts (biểu đồ tiến độ)

**🔄 Semester Switcher:**
- Đặt ở vị trí thuận tiện (tự quyết định)
- Mặc định: Load học kỳ hiện tại (latest)
- Có thể switch về các học kỳ trước
- **Học kỳ cũ = Read-only** (không submit bài, không làm quiz)

---

#### **Layer 2: Course Space (3 tabs)**

**Tab 1: Stream**
- Hiển thị announcements gần đây
- Comment threads ngắn để tương tác nhanh

**Tab 2: Classwork**
- Tập trung assignments, quizzes, materials
- Có tổ chức hệ thống
- **Phải có**: Search, sorting (cho datasets lớn)

**Tab 3: People**
- Danh sách groups
- Danh sách students trong course

**⚠️ Quy tắc tương tác:**
- Students: Xem được cả 3 tabs
- Students: KHÔNG được nhắn tin trực tiếp với nhau
- Chỉ được: Forum course/group + Private message với Instructor

---

#### **Layer 3: User Profile**

**Cả 2 roles:**
- Xem và chỉnh sửa thông tin cơ bản
- Avatar
- Các trường bổ sung
- **KHÔNG được đổi display name**
- **Username phải là tên thật** (Không được "user1", "user2")

---

### 🏫 2. SEMESTER–COURSE–GROUP–STUDENT MODEL

#### **A. Semester (Học kỳ)**
**Fields:**
- Code (mã học kỳ)
- Name (tên học kỳ)

**Quan hệ:**
- 1 Semester → N Courses

---

#### **B. Course (Khóa học)**
**Fields:**
- Course code
- Name
- Number of sessions: **ENUM('10', '15')**
- Description
- Semester ID (thuộc 1 semester)
- Instructor ID

**Quan hệ:**
- N Courses → 1 Semester
- 1 Course → N Groups

---

#### **C. Group (Nhóm/Lớp)**
**Fields:**
- Group ID
- Course ID

**Quan hệ:**
- N Groups → 1 Course
- 1 Group → N Students
- **Quy tắc**: Trong 1 course, 1 student CHỈ thuộc 1 group

**Ví dụ:**
```
Course: Web Programming
├─ Group 1 (30 students)
├─ Group 2 (25 students)
└─ Group 3 (28 students)
```

---

#### **D. Student (Sinh viên)**
**Quy trình:**
1. Instructor tạo student accounts trước
2. Sau đó assign vào groups phù hợp

**Ví dụ scenario:**
```
Học kỳ mới: 50 students
├─ 40 existing accounts → Chỉ cần assign vào group
└─ 10 new accounts → Tạo mới + assign vào group
```

**⚠️ YÊU CẦU QUAN TRỌNG:**
- Phải xử lý trường hợp này seamlessly và efficiently

---

#### **E. CSV IMPORT (Tính năng bắt buộc)**

**Yêu cầu cho TẤT CẢ bulk import:**
1. **Upload CSV** với validation
2. **Preview trước khi import**
3. **Xử lý duplicates thông minh:**
   - VD: Upload 50 students
   - 30 already exists
   - 20 mới
   - **KHÔNG được reject toàn bộ**
   - Hiển thị preview: "already exists" vs "will be added"
   - Cho phép user import chỉ 20 mới
4. **Post-import results screen**
   - Hiển thị status của từng item

**Áp dụng cho:**
- Semesters
- Courses
- Groups
- Student-Group assignments

---

### 📚 3. DISTRIBUTION OF LEARNING CONTENT (4 types)

#### **Type 1: ANNOUNCEMENT (Thông báo)**

**Fields:**
- Title
- Rich-text content
- File attachments (optional, multiple)

**Features:**
- **Scope selection**: 1 group, nhiều groups, hoặc all groups trong course
- **Comments**: Cả instructor và students có thể comment (style "social media")

**Instructor tracking:**
- Ai đã xem announcement
- Ai đã download file đính kèm (nếu có)

---

#### **Type 2: ASSIGNMENT (Bài tập)**

**Fields:**
- Title
- Description
- Multiple file/image attachments

**Settings:**
- Start date
- Deadline
- Late submission allowed? (Yes/No)
  - Nếu Yes: Late deadline
- Maximum submission attempts
- File format restrictions
- File size limit

**Scope:** By groups (giống announcement)

**Instructor tracking (Real-time):**
- Ai đã submit
- Ai chưa submit
- Late submissions
- Multiple attempts (2nd, 3rd submission)
- Current grades

**Phải có:**
- Filter, search, sort (by name, group, time, status)
- **CSV export**:
  - Individual assignment
  - All assignments trong 1 course
  - All assignments trong 1 semester

---

#### **Type 3: QUIZ (Bài kiểm tra)**

**Question Bank (Ngân hàng câu hỏi):**
- Reusable across semesters
- Per course
- Each question:
  - Multiple choices
  - 1 correct answer
  - Difficulty label: easy, medium, hard

**Quiz Configuration:**
- Time window: open time, close time
- Number of attempts
- Duration (phút)
- Random structure:
  - x easy questions
  - y medium questions
  - z hard questions

**Instructor tracking (Post-release):**
- Ai đã complete
- Ai chưa làm
- Scores
- Submission times

**Phải có:**
- **CSV export**:
  - Individual quiz
  - All quizzes trong 1 course
  - All quizzes trong 1 semester

---

#### **Type 4: MATERIAL (Tài liệu)**

**Fields:**
- Title
- Description
- One or more files/links

**Scope:**
- **KHÔNG có group scoping**
- Tự động visible cho ALL students trong course

**Instructor tracking:**
- Ai đã view
- Ai đã download

---

### 💬 4. INTERACTION, FORUMS, MESSAGING, NOTIFICATIONS

#### **A. FORUM**

**Features:**
- Topic creation per course
- **ALL enrolled students** có quyền ngang nhau
- Threaded replies (comment lồng nhau)
- File attachments
- Search functionality

---

#### **B. PRIVATE MESSAGING**

**Quy tắc:**
- ✅ Cho phép: Student ↔ Instructor
- ❌ CẤM: Student ↔ Student (direct message)
- Student muốn liên lạc với nhau: Dùng course/group forums

---

#### **C. NOTIFICATIONS**

**In-app Notifications:**
- ✅ CHỈ cho Students
- ❌ Instructors KHÔNG cần in-app notifications
- Phải có: Read/Unread status rõ ràng

**Email Notifications:**
- ✅ CHỈ cho Students
- ❌ Instructors KHÔNG nhận email
- **Bắt buộc gửi cho:**
  1. New announcements
  2. Approaching assignment/quiz deadlines
  3. Important feedback
  4. Confirmation of assignment/quiz submissions

---

### 🔍 5. SEARCH, SORTING, PERFORMANCE OPTIMIZATION

**Các màn hình phải có search/filter/sort:**
- Courses
- Groups
- Students
- Assignments
- Quizzes
- Materials
- Submissions

**Filters ví dụ:**
- By group
- By status
- By time

**Sorting ví dụ:**
- By name
- By deadline
- By score
- By update date

**Performance:**
- **Caching**:
  - Cache "category" data
  - Cache recent query results
- Giảm API calls
- Minimize response times
- Smooth experience under unstable network
- **Cache synchronization**: Khi switch semester hoặc refresh data
  - Đảm bảo KHÔNG có data inconsistencies

---

### 📊 6. STUDENT PRIVILEGES & PERSONAL DASHBOARD

**Personal Dashboard (Students):**
- Learning progress:
  - Submitted assignments
  - Pending assignments
  - Late assignments
- Completed quizzes với scores (nếu có)
- Chart/timeline of upcoming deadlines

**Past Semesters:**
- ❌ Disabled: Submit assignments, làm quizzes, editing
- ✅ Allowed: Read-only access for reference

---

### 🚀 7. DEPLOYMENT (BẮT BUỘC)

**Backend:**
- Tự do quyết định cách implement

**Frontend (Flutter):**
1. **APK** (Android arm64) - BẮT BUỘC
2. **EXE** (Windows 64-bit) hoặc **macOS app** - BẮT BUỘC
3. **Web version** - Deploy lên hosting (Firebase/GitHub Pages) - **+0.5 điểm**

**Lưu ý:**
- Phải cung cấp URL website
- Web phải chạy smoothly
- Giải quyết cold start issues (free backend services)
- Chuẩn bị wake-up scripts cho grading session

---

### 🎨 8. OTHER REQUIREMENTS

#### **A. UI/UX**
- Clear, user-friendly design
- Intuitive navigation
- Quick load times
- Easy interaction

#### **B. Responsive Design**
- Adapt seamlessly to different devices/screen sizes
- Use Bootstrap hoặc CSS Grid

#### **C. Team Collaboration (BẮT BUỘC)**
- Version control: Git
- GitHub Insights screenshots
- **Evidence bắt buộc:**
  - Project kéo dài ít nhất 1 tháng
  - Mỗi member: **≥2 commits/week**
- **Thiếu teamwork → -0.5 điểm**

#### **D. Offline Capability (BẮT BUỘC)**

**Students (offline mode):**
- View previously accessed:
  - Course materials
  - Announcements
  - Personal dashboard (submitted assignments, completed quizzes, upcoming deadlines)

**Instructors (offline mode):**
- View previously accessed:
  - Course data
  - Student lists
  - Tracking metrics

**Implementation:**
- Online DB + Offline DB (SQLite/Hive)
- Offline DB = synchronized copy of critical data
- Faster access + fallback when no internet

---

### 🎁 9. BONUS FEATURES (Mỗi feature +0.25-0.5 điểm, max 4 features)

1. **Self-built backend** (không dùng Firebase)
2. **Microservices** + Message queues (RabbitMQ/Redis) + Kubernetes
3. **AI chatbot** for learning support
4. **AI question/answer generation** from materials
5. **Other AI features** (phải có evidence)
6. **Publish lên store** (Google Play/App Store/Microsoft Store)

**Điểm bonus:**
- 0.25: Basic implementation (VD: Chỉ call OpenAI API)
- 0.5: Advanced (VD: RAG, fine-tuning, có benchmark)

---

## III. RUBRIC BREAKDOWN (10 điểm)

| Category | Điểm | Yêu cầu |
|----------|------|---------|
| Semester/Course/Group/Student Management | 2.0 | CRUD đầy đủ + CSV import thông minh |
| Content Delivery | 2.0 | 4 types content đầy đủ + tracking |
| Interaction & Notifications | 2.0 | Forum + Private chat + Notifications |
| Reports & Analytics | 2.0 | Dashboard + CSV export + Charts |
| Teamwork (GitHub Insights) | 0.5 | ≥2 commits/week/member, ≥1 month |
| Web Deployment | 0.5 | Public URL + smooth running |
| UI | 0.5 | Visually appealing + responsive |
| UX | 0.5 | Smooth + intuitive + fast |

**Tổng: 10 điểm**

---

## IV. ĐIỂM TRỪ

| Lỗi | Trừ điểm |
|-----|----------|
| Late submission (1 ngày) | -1.0 |
| Không có hướng dẫn compile/run | -2.0 |
| Không clean project trước nộp | -0.5 |
| Thiếu thông tin grading (username/password) | -1.0 |
| Thiếu teamwork evidence | -0.5 |

---

## V. ĐIỀU KIỆN 0 ĐIỂM (CỰC KỲ QUAN TRỌNG)

❌ **0 điểm nếu:**
1. Nội dung không liên quan đến IT (VD: nấu ăn, thể thao)
2. Code giống nhau giữa các nhóm (plagiarism)
3. Lấy code từ internet
4. Không nộp source code
5. Không nộp rubric.docx
6. Không deploy web hoặc không có APK/EXE
7. Không có instructions và giảng viên không chạy được project

---

## VI. NỘP BÀI

**Cấu trúc folder:**
```
id1_fullname1_id2_fullname2/
├── source/          (Source code Flutter + Backend + DB files)
├── bin/             (APK + EXE files)
├── demo.mp4         (Video demo, ≥1080p)
├── git/             (GitHub Insights screenshots)
├── readme.txt       (Hướng dẫn + URL + accounts)
├── bonus/           (Bonus features description)
└── rubrik.docx      (Self-assessment)
```

**Nén thành:** `id1_fullname1_id2_fullname2.zip`

**Nộp:** Chỉ qua elearning (KHÔNG qua email)

---

## VII. DEMO VIDEO YÊU CẦU

1. **Tất cả members** phải tham gia
2. Giới thiệu technologies + architecture
3. Demo TUẦN TỰ từng feature
4. **Không demo = Không có điểm** (dù có trong code)
5. Resolution: ≥1080p
6. Audio: Clear, dễ hiểu
7. Nếu quá lớn: Upload YouTube + include link
