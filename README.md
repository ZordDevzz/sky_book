# sky_book

Sky Book - Your trusted reading companion.

## Next Steps - Roadmap cho project:

### **Phase 1: UI Foundation**
- [x] Setup project structure
- [x] Theme system (light/dark)
- [x] Navigation system
- [ ] Design screens với dummy data

### **Phase 2: Data Layer**
- [ ] Setup models (Book, User, Chapter, etc.)
- [ ] API integration hoặc local database
- [x] State management (Provider)

### **Phase 3: Core Features**
- [ ] Book listing & detail page
- [ ] Reading screen với các controls (font size, brightness, etc.)
- [ ] Authentication (login/register)
- [ ] User profile & settings

### **Phase 4: Advanced Features**
- [ ] Offline reading
- [ ] Bookmarks & highlights
- [ ] Comments & reviews
- [ ] Leaderboard system
- [ ] Search & filters

### **Phase 5: Polish**
- [ ] Animations & transitions
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states

---

## Cấu trúc folder dự định (có thể sửa đổi):

```
lib/
├── main.dart
├── pages/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── shelf_screen.dart
│   │   ├── discover_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   └── profile_screen.dart
│   ├── book/
│   │   ├── book_detail_page.dart
│   │   └── reading_page.dart
│   └── auth/
│       ├── login_page.dart
│       └── register_page.dart
├── widgets/
│   ├── book_card.dart
│   ├── book_list.dart
│   └── chapter_list.dart
├── models/
│   ├── book.dart
│   ├── user.dart
│   ├── chapter.dart
│   └── review.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── providers/ (Provider)
│   ├── book_provider.dart
│   └── user_provider.dart
└── theme/
    └── app_theme.dart