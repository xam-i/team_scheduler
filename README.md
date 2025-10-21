# Team Scheduler - Auto-Slot Finder

A real-time collaborative Team Scheduler built with Flutter Web, iOS, and Android using Supabase backend. Users can register with name & photo, set their availability, and create tasks with collaborators. The system calculates and displays common available time slots based on collaborators' availability and chosen task duration.

## Features

- **User Registration**: Users can register with their name and profile photo
- **Availability Management**: Set and manage personal availability time slots
- **Task Creation**: Create tasks with collaborators in a 4-step process:
  1. Task details (title and description)
  2. Choose collaborators
  3. Select task duration (10, 15, 30, or 60 minutes)
  4. Choose from calculated available time slots
- **Smart Slot Finding**: Automatically calculates common available time slots for all collaborators
- **Task Management**: View, filter, and manage tasks with different views (All, Created, Mine)
- **Real-time Collaboration**: Built with Supabase for real-time updates

## Tech Stack

- **Frontend**: Flutter (Web, iOS, Android)
- **State Management**: BLoC/Cubit pattern
- **Backend**: Supabase (PostgreSQL + Real-time + Storage)
- **Architecture**: Clean Architecture with Repository pattern

## Project Structure

```
lib/
├── core/
│   ├── bloc/           # State management (User, Availability, Task Cubits)
│   ├── config/         # Supabase configuration
│   ├── models/         # Data models
│   ├── repositories/   # Data access layer
│   └── services/       # Business logic (Slot finder algorithm)
└── presentation/
    └── pages/          # UI pages
        ├── onboarding_page.dart
        ├── home_page.dart
        ├── availability_page.dart
        ├── add_availability_page.dart
        ├── task_list_page.dart
        └── create_task_page.dart
```

## Database Schema

### Users Table
- `id` (uuid, primary key)
- `name` (text, not null)
- `photo_url` (text, nullable)
- `created_at` (timestamptz, default now)

### Availability Table
- `id` (bigint, primary key, auto-generated)
- `user_id` (uuid, foreign key to users)
- `start_time` (timestamptz, not null)
- `end_time` (timestamptz, not null)
- `created_at` (timestamptz, default now)

### Tasks Table
- `id` (bigint, primary key, auto-generated)
- `title` (text, not null)
- `description` (text, nullable)
- `created_by` (uuid, foreign key to users)
- `start_time` (timestamptz, nullable)
- `end_time` (timestamptz, nullable)
- `created_at` (timestamptz, default now)

### Task Collaborators Table
- `id` (bigint, primary key, auto-generated)
- `task_id` (bigint, foreign key to tasks)
- `user_id` (uuid, foreign key to users)
- Unique constraint on (task_id, user_id)

## Key Features Implementation

### Slot Finding Algorithm
The app includes a sophisticated algorithm that:
1. Collects availability data for all collaborators
2. Finds intersections between availability windows
3. Filters slots that meet the minimum duration requirement
4. Merges overlapping time slots
5. Sorts results by start time

### User Experience
- **Onboarding**: Clean, intuitive user registration with photo upload
- **Availability Management**: Easy-to-use interface for adding/deleting availability slots
- **Task Creation**: Step-by-step wizard with validation and real-time slot calculation
- **Task List**: Filterable view with different perspectives (All, Created, Mine)

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Supabase account

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Supabase:
   - Update `lib/core/config/supabase_config.dart` with your Supabase credentials
   - Set up the database schema as described above

4. Run the app:
   ```bash
   # For web
   flutter run -d web-server --web-port 8080
   
   # For mobile
   flutter run
   ```

## Deployment

The app is designed to run on multiple platforms:
- **Web**: Deploy to any web hosting service (Firebase Hosting, Vercel, etc.)
- **Mobile**: Build APK/IPA files for distribution
- **Backend**: Supabase handles all backend services

## Contributing

This project follows Flutter best practices:
- Clean Architecture
- BLoC pattern for state management
- Repository pattern for data access
- Comprehensive error handling
- Responsive design

## License

This project is part of the Ascimov Machine Test and demonstrates full-stack Flutter development capabilities.