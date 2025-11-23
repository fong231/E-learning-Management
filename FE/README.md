# LMS - Learning Management System (Flutter)

Hệ thống quản lý học tập (LMS) được xây dựng bằng Flutter, hỗ trợ cả sinh viên và giảng viên.

## Tính năng chính

### Cho Sinh viên
- ✅ Xem danh sách khóa học đã đăng ký
- ✅ Xem tài liệu học tập
- ✅ Làm bài tập và nộp bài
- ✅ Làm bài kiểm tra trực tuyến
- ✅ Tham gia diễn đàn thảo luận
- ✅ Nhắn tin với giảng viên
- ✅ Nhận thông báo
- ✅ **AI Trợ lý học tập** (Bonus Feature) - Chatbot AI hỗ trợ học tập sử dụng Google Gemini

### Cho Giảng viên
- ✅ Quản lý khóa học
- ✅ Tạo và quản lý bài tập
- ✅ Tạo và quản lý bài kiểm tra
- ✅ Quản lý sinh viên
- ✅ Chấm điểm và phản hồi
- ✅ Đăng thông báo
- ✅ Nhắn tin với sinh viên

## Kiến trúc

Dự án sử dụng **Clean Architecture** với 3 layers:

```
lib/
├── core/                 # Core utilities, constants, themes
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── data/                 # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── services/        # API services
└── presentation/        # Presentation layer
    ├── providers/       # State management (Provider)
    ├── screens/         # UI screens
    └── widgets/         # Reusable widgets
```

## Yêu cầu hệ thống

- Flutter SDK: >= 3.0.0
- Dart SDK: >= 3.0.0
- Backend API: http://localhost:8080

## Cài đặt

### 1. Clone repository

```bash
git clone <repository-url>
cd FE
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình API Key cho AI Chatbot

Mở file `lib/core/constants/app_constants.dart` và thay thế API key:

```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Để lấy API key miễn phí:
1. Truy cập https://makersuite.google.com/app/apikey
2. Đăng nhập bằng tài khoản Google
3. Tạo API key mới
4. Copy và paste vào file constants

### 4. Chạy ứng dụng

```bash
flutter run
```

## Cấu trúc Backend API

Backend API cần chạy tại `http://localhost:8080` với các endpoints:

- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/register` - Đăng ký
- `GET /api/courses` - Lấy danh sách khóa học
- `GET /api/assignments` - Lấy danh sách bài tập
- `GET /api/quizzes` - Lấy danh sách bài kiểm tra
- `GET /api/messages` - Lấy tin nhắn
- `GET /api/notifications` - Lấy thông báo
- Và nhiều endpoints khác...

## Dependencies chính

- **provider**: State management
- **http** & **dio**: HTTP client
- **shared_preferences**: Local storage
- **google_generative_ai**: AI chatbot (Gemini)
- **file_picker**: File upload
- **flutter_markdown**: Markdown rendering

## Tài khoản demo

### Sinh viên
- Email: student@example.com
- Password: student123

### Giảng viên
- Email: instructor@example.com
- Password: instructor123

## Màn hình chính

### Authentication
- Login Screen
- Register Screen

### Student Screens
- Dashboard
- Courses List & Detail
- Assignments
- Quizzes
- Messages
- Notifications
- Forum
- AI Chat (Bonus)
- Profile

### Instructor Screens
- Dashboard
- Courses Management
- Create/Edit Course
- Create Assignment
- Create Quiz
- Students Management
- Messages
- Profile

## Bonus Feature: AI Chatbot

Tính năng AI Chatbot sử dụng Google Gemini AI để:
- Giải đáp thắc mắc về bài học
- Hướng dẫn làm bài tập
- Tóm tắt nội dung học tập
- Gợi ý phương pháp học hiệu quả

## Build cho production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

### Lỗi kết nối API
- Kiểm tra backend đang chạy tại http://localhost:8080
- Kiểm tra firewall/antivirus

### Lỗi AI Chatbot
- Kiểm tra API key đã được cấu hình đúng
- Kiểm tra kết nối internet
- Đảm bảo API key còn quota

## License

MIT License

## Tác giả

- Nguyễn Thế Phong - 523H0076
- Nguyễn Huỳnh Hải Đăng - 523H0010
- Lê Minh Kha - 523H0036
