# ReqRes Flutter App

A Flutter application demonstrating authentication, user management, and state persistence using the ReqRes API.

## Features

- **Authentication**
  - Login and registration with persistent state
  - Secure storage for authentication tokens
  - Automatic login on app restart

- **User Management**
  - View list of users with pagination
  - Search and filter users by name or email
  - Create new users
  - Edit existing users
  - Delete users with confirmation

- **UI/UX Enhancements**
  - Form validation
  - Loading indicators
  - Error handling with user-friendly messages
  - Toast notifications for action feedback
  - Responsive design

## API Notes

This app uses the ReqRes API (https://reqres.in/) for testing.

For testing purposes:
- Login: Use email: `eve.holt@reqres.in` and password: `cityslicka`
- Register: Use email: `eve.holt@reqres.in` and password: `pistol`

Note: The API simulates responses but doesn't persist all changes.

## Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the app

## Technologies Used

- Flutter
- Provider for state management
- Flutter Secure Storage for persistence
- HTTP package for API requests