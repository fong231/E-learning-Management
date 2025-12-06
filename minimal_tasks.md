# DANH SÁCH CÔNG VIỆC TỐI THIỂU - HOÀN THÀNH NHANH

## ⚠️ LƯU Ý: Làm ĐÚNG những phần này để TRÁNH 0 ĐIỂM

### 🚫 BẮT BUỘC (Thiếu = 0 điểm):
1. APK (Android arm64)
2. Windows EXE hoặc macOS app
3. Web deployment (public URL)
4. Source code + readme.txt + rubrik.docx
5. GitHub Insights (≥1 tháng, ≥2 commits/week/member)
6. Demo video (1080p, all members)

---

## 🎯 TIMELINE TỐI THIỂU: 6-7 TUẦN

---

## WEEK 1: SETUP CƠ BẢN

### ✅ Day 1-2: Project Setup (BẮT BUỘC)
- [ ] Tạo Flutter project
- [ ] Setup Git + GitHub (BẮT BUỘC cho teamwork)
- [ ] **Commit ngay:** "Initial project setup"

### ✅ Day 3-4: Database (Dùng Firebase - NHANH NHẤT)
**⚡ Khuyến nghị: Dùng Firebase Firestore (không cần bonus)**
- [ ] Tạo Firebase project
- [ ] Add Firebase to Flutter
- [ ] Setup Firestore collections:
  ```
  - users (customers, role)
  - semesters
  - courses
  - groups
  - student_groups (enrollment)
  - announcements
  - assignments
  - quizzes
  - questions
  - materials
  - notifications
  - messages
  ```
- [ ] Setup Firebase Authentication
- [ ] **Setup Hive cho offline DB** (BẮT BUỘC)

### ✅ Day 5-7: Authentication
- [ ] Login screen (admin/admin + students)
- [ ] Auto-login với token
- [ ] Role-based routing (Instructor vs Student)
- [ ] Logout
- [ ] **Commit:** "Auth completed"

**📦 Dependencies cần thiết:**
```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  hive: ^latest
  hive_flutter: ^latest
  provider: ^latest
  cached_network_image: ^latest
  file_picker: ^latest
  image_picker: ^latest
  intl: ^latest
```

---

## WEEK 2: QUẢN LÝ CƠ BẢN (2 điểm)

### ✅ Semester Management (ĐƠN GIẢN NHẤT)
- [ ] List semesters
- [ ] Add semester form (chỉ code + name)
- [ ] Edit/Delete semester
- [ ] **BỎ QUA CSV import** (làm sau nếu còn thời gian)

### ✅ Course Management
- [ ] List courses với search
- [ ] Add course form:
  - Course code, Name
  - Number of sessions (dropdown: 10 hoặc 15)
  - Semester selection
- [ ] Edit/Delete course
- [ ] **BỎ QUA CSV import**

### ✅ Group Management
- [ ] List groups per course
- [ ] Add group (chỉ cần group_id)
- [ ] Delete group

### ✅ Student Management (QUAN TRỌNG)
- [ ] List students với search
- [ ] Add student form (fullname, email, username, password)
- [ ] Assign student to group (dropdown)
- [ ] **Validation:** 1 student CHỈ 1 group trong 1 course
- [ ] **BỎ QUA CSV import ban đầu**

**🎯 Commit mỗi ngày:** "Semester CRUD done", "Course CRUD done", etc.

---

## WEEK 3: HOMEPAGE & COURSE TABS

### ✅ Student Homepage
- [ ] Display enrolled courses as cards
  - Cover image (placeholder OK)
  - Course name
  - Instructor name
- [ ] Semester switcher (dropdown đơn giản)

### ✅ Instructor Dashboard (ĐƠN GIẢN)
- [ ] Show metrics (count từ Firestore):
  - Total courses
  - Total groups
  - Total students
- [ ] **BỎ QUA charts** (làm sau nếu còn thời gian)

### ✅ Course Tabs (3 tabs CƠ BẢN)
- [ ] **Tab Stream:** List announcements
- [ ] **Tab Classwork:** List assignments + materials
- [ ] **Tab People:** List groups + students

**📝 Note:** Chỉ cần hiển thị list đơn giản, chưa cần search/filter phức tạp

---

## WEEK 4: ANNOUNCEMENT & ASSIGNMENT (2 điểm)

### ✅ Announcement (QUAN TRỌNG)
**Instructor:**
- [ ] Create announcement:
  - Title, Content (TextField đơn giản, BỎ rich-text editor)
  - Upload files (file_picker)
  - Select groups (checkbox list)
- [ ] View announcement
- [ ] **BỎ QUA tracking views/downloads** (làm sau)

**Student:**
- [ ] View announcements
- [ ] Download files
- [ ] **BỎ QUA comments** (làm sau nếu còn thời gian)

### ✅ Assignment (QUAN TRỌNG)
**Instructor:**
- [ ] Create assignment:
  - Title, Description
  - Deadline (DatePicker)
  - **BỎ QUA:** late_deadline, file format, size limit (làm sau)
  - Select groups
- [ ] View submissions list (simple table)
- [ ] Grade assignment (simple input field)
- [ ] **BỎ QUA CSV export** (làm sau)

**Student:**
- [ ] View assignments
- [ ] Submit assignment (upload file)
- [ ] View grade

---

## WEEK 5: QUIZ & MATERIAL (2 điểm)

### ✅ Quiz (ĐƠN GIẢN HÓA)
**Instructor:**
- [ ] Create questions (A, B, C, D, correct answer, difficulty)
- [ ] Create quiz:
  - Title
  - Duration
  - Select questions manually (checkbox)
  - **BỎ QUA:** random structure, open/close time

**Student:**
- [ ] View quizzes
- [ ] Take quiz (timer)
- [ ] Auto-submit when time's up
- [ ] View score immediately

### ✅ Material (DỄ NHẤT)
**Instructor:**
- [ ] Create material:
  - Title
  - Upload files
- [ ] View materials

**Student:**
- [ ] View materials
- [ ] Download files

---

## WEEK 6: MESSAGING & NOTIFICATIONS (2 điểm)

### ✅ Forum (ĐƠN GIẢN)
- [ ] Create topic (title + description)
- [ ] View topics list
- [ ] Reply to topic (flat, không threaded)
- [ ] **BỎ QUA:** file attachments, search

### ✅ Private Messaging (QUAN TRỌNG)
- [ ] Conversations list
- [ ] Send message (Student ↔ Instructor ONLY)
- [ ] View messages
- [ ] **BỎ QUA:** real-time updates

### ✅ Notifications (CHỈ cho Students)
- [ ] List notifications (in-app)
- [ ] Read/Unread status
- [ ] Mark as read
- [ ] **BỎ QUA:** Email notifications (làm sau)

**Tạo notifications khi:**
- New announcement posted
- Assignment deadline approaching
- New message received

---

## WEEK 7: DASHBOARD & OFFLINE (2 điểm)

### ✅ Student Dashboard
- [ ] Show stats:
  - Submitted assignments
  - Pending assignments
  - Completed quizzes with scores
- [ ] Upcoming deadlines list (simple list)
- [ ] **BỎ QUA charts** (làm sau)

### ✅ Offline Mode (BẮT BUỘC)
**Setup Hive boxes:**
```dart
- coursesBox
- announcementsBox
- materialsBox
- dashboardBox
```

**Implement:**
- [ ] Check network status
- [ ] Save data to Hive when online
- [ ] Load from Hive when offline
- [ ] Show "Offline Mode" indicator
- [ ] **BỎ QUA:** complex sync mechanism

---

## WEEK 8: UI/UX & POLISH

### ✅ UI Improvements (BẮT BUỘC cho điểm UI/UX)
- [ ] Consistent color theme
- [ ] Loading indicators (CircularProgressIndicator)
- [ ] Empty states ("No data available")
- [ ] Error handling (SnackBar)
- [ ] Form validation

### ✅ Responsive Design
- [ ] Test on Android (phone)
- [ ] Test on Windows
- [ ] Test on Web browser
- [ ] Fix layout issues

### ✅ Search & Filter (CƠ BẢN)
- [ ] Search bar cho:
  - Courses
  - Students
  - Assignments
- [ ] **BỎ QUA:** Advanced filters, sorting

---

## WEEK 9: DEPLOYMENT (BẮT BUỘC)

### ✅ Build APK
```bash
flutter build apk --target-platform android-arm64 --release
```
- [ ] Test APK trên Android device
- [ ] Copy vào folder `bin/`

### ✅ Build Windows EXE
```bash
flutter build windows --release
```
- [ ] Test EXE
- [ ] Copy vào folder `bin/`

### ✅ Deploy Web (0.5 điểm)
**Option 1: Firebase Hosting (NHANH NHẤT)**
```bash
flutter build web --release
firebase deploy --only hosting
```

**Option 2: GitHub Pages**
```bash
flutter build web --release --base-href "/repo-name/"
# Push to gh-pages branch
```

- [ ] Get public URL
- [ ] Test URL publicly
- [ ] Add URL vào readme.txt

### ✅ Wake-up Script (nếu dùng free backend)
Tạo file `wakeup.sh`:
```bash
#!/bin/bash
curl https://your-backend-url.com/health
```

---

## WEEK 10: SUBMISSION

### ✅ GitHub Insights (BẮT BUỘC - 0.5 điểm)
- [ ] Take screenshots từ GitHub Insights
- [ ] Show contributions từng member
- [ ] Verify: ≥1 month, ≥2 commits/week/member
- [ ] Save vào folder `git/`

### ✅ Demo Video (BẮT BUỘC)
**Script:**
1. Intro: Team members
2. Tech stack: Flutter + Firebase + Hive
3. Demo features (10-15 phút):
   - Login (admin + student)
   - Create semester/course/group/student
   - Create announcement
   - Create assignment → Student submit → Grade
   - Create quiz → Student take quiz
   - Materials
   - Forum topic + reply
   - Private messaging
   - Notifications
   - Student dashboard
   - Offline mode (turn off WiFi, show data still loads)

**Requirements:**
- [ ] 1080p resolution
- [ ] Clear audio
- [ ] All members appear
- [ ] 10-20 minutes

### ✅ Folder Structure
```
id1_name1_id2_name2/
├── source/
│   └── flutter_app/
├── bin/
│   ├── app-release.apk
│   └── windows_executable.exe
├── demo.mp4
├── git/
│   └── insights.png
├── readme.txt
└── rubrik.docx
```

### ✅ Readme.txt
```
PROJECT: E-Learning Management System
TEAM: [Names and IDs]

TECH STACK:
- Frontend: Flutter
- Database: Firebase Firestore + Hive (offline)
- Authentication: Firebase Auth

WEB URL: https://your-app.web.app

TEST ACCOUNTS:
- Instructor: admin / admin
- Student 1: student1 / password123
- Student 2: student2 / password123

BUILD INSTRUCTIONS:
1. flutter pub get
2. flutter run

FEATURES IMPLEMENTED:
✅ Authentication
✅ Semester/Course/Group/Student Management
✅ Announcement
✅ Assignment (submit + grade)
✅ Quiz (create + take)
✅ Material
✅ Forum
✅ Private Messaging
✅ Notifications
✅ Student Dashboard
✅ Offline Mode
✅ Web/APK/EXE

KNOWN LIMITATIONS:
- No CSV import (ran out of time)
- No rich text editor (simple TextField)
- No email notifications (in-app only)
- No charts (simple stats only)
```

### ✅ Rubrik.docx
- [ ] Download từ instructor
- [ ] Fill self-assessment
- [ ] Add web URL
- [ ] Add test accounts

### ✅ Clean Project
```bash
flutter clean
# Remove unnecessary files:
- .dart_tool/
- build/ (except release builds)
- .idea/
- *.iml
```

### ✅ Final Checks
- [ ] APK installs and runs
- [ ] EXE opens and runs
- [ ] Web URL accessible
- [ ] All files in correct folders
- [ ] Zip file < 100MB
- [ ] Upload to elearning

---

## 🎯 BỎ QUA HOÀN TOÀN (Làm sau nếu còn thời gian)

### ❌ Không làm để tiết kiệm thời gian:
1. **CSV Import/Export** - Phức tạp, tốn thời gian
2. **Rich Text Editor** - Dùng TextField đơn giản
3. **Charts/Graphs** - Chỉ hiển thị numbers
4. **Email Notifications** - Chỉ làm in-app
5. **Advanced Filters/Sorting** - Chỉ basic search
6. **View/Download Tracking** - Không cần thiết
7. **Comment Threads** - Flat comments thôi
8. **Real-time Updates** - Refresh manual
9. **File Format/Size Validation** - Basic validation thôi
10. **Late Submission Logic** - Chỉ có 1 deadline

---

## 📊 ĐIỂM DỰ KIẾN VỚI VERSION TỐI THIỂU

| Category | Target | Note |
|----------|--------|------|
| Semester/Course/Group/Student | 1.5/2.0 | Thiếu CSV import |
| Content Delivery | 1.5/2.0 | Basic features OK |
| Interaction & Notifications | 1.5/2.0 | Thiếu email, threaded replies |
| Reports & Analytics | 1.0/2.0 | Thiếu CSV export, charts |
| Teamwork | 0.5/0.5 | ✅ BẮT BUỘC làm đủ |
| Web Deployment | 0.5/0.5 | ✅ BẮT BUỘC |
| UI | 0.3/0.5 | Basic UI |
| UX | 0.3/0.5 | Basic UX |
| **TOTAL** | **~7.1/10** | **Đủ điểm qua môn** |

---

## ⏰ THỜI GIAN THỰC TẾ CHO TỪNG PHASE

| Week | Hours | Tasks |
|------|-------|-------|
| 1 | 20h | Setup + Auth |
| 2 | 25h | Management CRUD |
| 3 | 15h | Homepage + Tabs |
| 4 | 20h | Announcement + Assignment |
| 5 | 20h | Quiz + Material |
| 6 | 20h | Messaging + Notifications |
| 7 | 15h | Dashboard + Offline |
| 8 | 10h | UI/UX Polish |
| 9 | 10h | Deployment |
| 10 | 10h | Video + Submission |
| **TOTAL** | **~165h** | **≈ 6-7 weeks** |

---

## 💡 TIPS ĐỂ LÀM NHANH

1. **Dùng Firebase** - Không cần tự code backend
2. **UI đơn giản** - MaterialDesign mặc định
3. **Copy-paste code** - Reuse widgets
4. **Commit thường xuyên** - Đảm bảo GitHub Insights
5. **Test ngay** - Đừng để cuối mới test
6. **Chia task rõ ràng** - Mỗi người 1 feature
7. **Daily commits** - Ít nhất 2 commits/week/member

---

## 🚨 CHECKLIST TRƯỚC KHI NỘP

- [ ] APK chạy được
- [ ] EXE/macOS chạy được
- [ ] Web URL public
- [ ] Login admin/admin works
- [ ] Create course → Create assignment → Student submit → Grade
- [ ] Create quiz → Student take quiz → See score
- [ ] Offline mode: Turn off WiFi, app vẫn show data
- [ ] GitHub Insights đủ 1 tháng, 2+ commits/week
- [ ] Demo video có tất cả members
- [ ] Readme.txt đầy đủ
- [ ] Rubrik.docx filled
- [ ] Zip file ready

---

## 🎯 NẾU CÒN THỜI GIAN THÊM

**Priority thấp xuống cao:**
1. Add charts (fl_chart package)
2. CSV import students
3. CSV export assignments
4. Rich text editor (flutter_quill)
5. Email notifications (mailer package)
6. Advanced search/filters
7. View/download tracking

**Mỗi feature thêm ≈ 0.2-0.3 điểm**
