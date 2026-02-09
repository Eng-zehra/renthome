# RentHome - Premium Rental Home Application

A full-stack rental home application built with Node.js/Express (Backend) and Flutter (Mobile App).

## Tech Stack
- **Backend**: Node.js, Express.js, MySQL, JWT, Bcrypt
- **Frontend**: Flutter, Provider (State Management), Google Fonts, LineIcons
# hello my name im from im very short
## Project Structure
- `/backend`: Node.js Express API
    - `/config`: Database and schema configuration
    - `/controllers`: API logic
    - `/models`: Database models
    - `/routes`: API endpoints
    - `/middleware`: Auth and Error handling
- `/frontend`: Flutter Mobile Application
    - `/lib/models`: Data models
    - `/lib/providers`: State management
    - `/lib/screens`: UI screens
    - `/lib/services`: API communication
    - `/lib/widgets`: Reusable UI components

## Getting Started

### Backend Setup session
1. Navigate to `/backend`
2. Run `npm install`
3. Create a MySQL database named `renthome_db`
4. Use `backend/config/schema.sql` to create the tables
5. Configure `.env` with your database credentials
6. Run `npm start` (or `node app.js`)

### Frontend Setup
1. Navigate to `/frontend`
2. Run `flutter pub get`
3. Update `lib/services/api_service.dart` with your local machine's IP address (instead of `localhost` if running on a real device/emulator)
4. Run `flutter run`

## Features Implemented
- [x] User Authentication (Register/Login) with JWT
- [x] Modern UI Design (Onboarding, Home, Explore)
- [x] Responsive Listing Cards
- [x] Bottom Navigation with 5 tabs
- [x] Centralized State Management
- [x] Centralized Error Handling
