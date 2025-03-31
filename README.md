# Task Manager App

## Overview
This is a **Task Manager App** built with **Flutter**, **Supabase**, and **Riverpod** for state management. The app allows users to manage their tasks with features like adding, updating, and completing tasks, while also providing task recommendations based on previously completed tasks. It utilizes **Shimmer effects** for better user experience during loading. 

## Features

- **Task Management**: Add, update, delete, and mark tasks as completed.
- **Task Recommendations**: Get task recommendations based on completed tasks, rather than pending tasks.
- **Shimmer Effect**: Display shimmer animations during data fetching to improve the loading experience.
- **Pull to Refresh**: Users can refresh the tasks by pulling down the list.
- **Scroll-to-Fetch**: Fetch additional tasks when the user scrolls to the bottom of the list.

## Technologies Used
- **Flutter**: Framework for building the mobile app.
- **Riverpod**: State management solution for Flutter.
- **Supabase**: Backend as a service, used for user authentication and database management.
- **Twilio**: Used for SMS-based OTP authentication.
- **Shimmer Effect**: For a loading skeleton during network requests.

## Project Structure
```
lib/
├── main.dart                     # Entry point of the application  
├── screens/                      # Contains screen widgets  
│   ├── task_list_screen.dart      # Displays pending tasks  
│   ├── completed_task_screen.dart # Displays completed tasks  
│   ├── landing_page.dart          # Initial landing page of the app  
│   ├── home_screen.dart           # Main screen after login  
│   ├── edit_task_screen.dart      # Allows users to edit an existing task  
│   ├── create_task_screen.dart    # Allows users to create a new task  
│   └── auth_screen.dart           # Handles user authentication  
├── providers/                     # Contains state management logic  
│   └── task_provider.dart         # Manages tasks state  
├── services/                      # Contains business logic and API requests  
│   ├── auth_service.dart          # Handles authentication logic  
│   ├── supabase_service.dart      # Manages Supabase interactions  
│   ├── task_service.dart          # Manages task CRUD operations  
│   └── user_service.dart          # Handles user-related operations  
├── widgets/                       # Custom reusable widgets  
│   └── task_tile.dart             # Displays individual task details  
└── supabase/                      # Contains Supabase Edge Functions  
    └── functions/                 # Supabase function definitions  
        └── getTaskRecommendations/  
            └── getTaskRecommendations.ts # Edge function for task recommendations
```

## Prerequisites
Before running this project, make sure to have the following installed on your machine:
- Flutter SDK
- Dart
- A compatible code editor (like VS Code or Android Studio)

## Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/task_manager_app.git
cd task_manager_app
```

### 2. Install Dependencies
Run the following command to get all the dependencies.
```bash
flutter pub get
```

### 3. Configure Supabase and Twilio
Create a new project in Supabase.

Set up a "tasks" table with the following fields:
- `id`: Integer (Primary Key)
- `title`: String
- `description`: String
- `status`: String (Values: "pending", "completed")
- `due_date`: Timestamp
- `completed_at`: Timestamp (Optional)
- `user_id`: UUID (Foreign Key referencing the user table)

In the `.env` file (or directly in your code), add your Supabase URL and Supabase Anon Key like so:
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

#### Twilio Authentication:
The app uses Twilio for SMS-based OTP authentication.
> **Important:** Since you are using the free version of Twilio for authentication, only registered phone numbers can be authenticated. You’ll need to ensure the phone number is added and verified in your Twilio account for it to work.

Make sure your Twilio credentials are also included in the `.env` file.

### 4. Run the App
Run the following command to start the app on an emulator or connected device.
```bash
flutter run
```

### 5. API Setup
To make the backend work:
- Create Supabase functions (if required for handling specific logic like fetching tasks based on status).
- Ensure authentication is set up for the users.
- Use the `GET` method for fetching the tasks and recommendations.

## Usage
### Task Management
- **Add Task**: Users can add new tasks by providing a title, description, priority, and due date.
- **Mark Task as Completed**: When a task is completed, it will be moved to the "Completed Tasks" section.
- **Task Recommendations**: When viewing tasks, the app will show recommended tasks based on previously completed ones.

### Shimmer Effect
- The Shimmer effect is shown while the app fetches data, providing a better visual experience during loading.

### Pull to Refresh
- Users can pull down the task list to refresh and fetch the latest tasks.

### Scroll to Fetch
- The app fetches more tasks as the user scrolls to the bottom of the task list.

## API Endpoints
### 1. Fetch Tasks
**GET** `/tasks`

Fetches all tasks for the authenticated user.

#### Response:
```json
{
  "tasks": [
    {
      "id": 1,
      "title": "Task Title",
      "description": "Task Description",
      "status": "pending",
      "due_date": "2025-04-01T10:00:00",
      "user_id": "user-id"
    }
  ]
}
```

### 2. Fetch Task Recommendations
**GET** `/tasks/recommendations`

Fetches task recommendations based on previously completed tasks.

#### Response:
```json
{
  "recommendations": [
    {
      "id": 1,
      "title": "Recommended Task",
      "description": "Description of the recommended task",
      "status": "completed",
      "due_date": "2025-03-15T10:00:00",
      "user_id": "user-id"
    }
  ]
}
```

## Video Demo
https://github.com/user-attachments/assets/71877731-6e29-4e42-afb7-0e04c61d0afd


## Contribution
Contributions are welcome! If you'd like to improve this app, feel free to fork the repository, make changes, and submit a pull request.

### Steps to Contribute
1. Fork the repository.
2. Create a new branch for your changes.
3. Make your changes.
4. Commit and push your changes.
5. Open a pull request.

## License
This project is licensed under the MIT License - see the `LICENSE` file for details.

## Acknowledgments
- **Flutter**: For making mobile app development easier.
- **Supabase**: For providing the backend services.
- **Riverpod**: For state management.
- **Twilio**: For handling SMS-based authentication.
- **Shimmer Effect**: For enhancing the UI during loading.

---

**Notes:**
- Replace placeholder values like `yourusername`, `your-project.supabase.co`, and `your-anon-key` with actual project details.
- Ensure the `.env` file is properly set up before running the app.
- Update the **Video Demo** section if applicable.
