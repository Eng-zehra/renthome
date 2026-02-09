# RentHome Security & Role-Based Access Control

## Overview
This document outlines the security measures implemented in the RentHome application to ensure that regular users cannot upload, edit, or delete properties. Only administrators have these privileges.

## Backend Security (API Level)

### Protected Routes
All sensitive property operations are protected by TWO layers of middleware:

1. **`protect`** - Ensures the user is authenticated (logged in)
2. **`admin`** - Ensures the user has admin role

#### Property Routes (`/api/properties`)
```javascript
// CREATE - Admin Only
POST /api/properties
Middleware: protect, admin
Action: Create new property

// UPDATE - Admin Only  
PUT /api/properties/:id
Middleware: protect, admin
Action: Update existing property

// DELETE - Admin Only
DELETE /api/properties/:id
Middleware: protect, admin
Action: Delete property

// READ - Public Access
GET /api/properties
Middleware: None
Action: View all properties

GET /api/properties/:id
Middleware: None
Action: View single property
```

### Authentication Middleware
Located in: `backend/middleware/authMiddleware.js`

**protect middleware:**
- Verifies JWT token from request headers
- Decodes user information
- Blocks request if token is invalid or missing

**admin middleware:**
- Checks if authenticated user has `role === 'admin'`
- Returns 403 Forbidden if user is not an admin
- Must be used AFTER protect middleware

## Frontend Security (UI Level)

### Admin-Only UI Elements

#### 1. Profile Tab
**Location:** `frontend/lib/screens/profile_tab.dart`

Admin Dashboard option only visible to admins:
```dart
if (isAdmin)
  _buildOption(LineIcons.userShield, 'Admin Dashboard', () {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const AdminAddPropertyScreen()
    ));
  }),
```

#### 2. Explore Tab (Property Listings)
**Location:** `frontend/lib/screens/explore_tab.dart`

Edit and Delete buttons only visible to admins:
```dart
if (isAdmin)
  Positioned(
    top: 15,
    left: 15,
    child: Row(
      children: [
        // Edit Button
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => AdminAddPropertyScreen(property: p)
            ));
          },
          child: Icon(LineIcons.edit),
        ),
        // Delete Button
        GestureDetector(
          onTap: () => _showDeleteDialog(context, p),
          child: Icon(LineIcons.trash),
        ),
      ],
    ),
  ),
```

### Role Detection
The app checks user role from the authenticated user object:
```dart
final user = Provider.of<AuthProvider>(context).user;
final isAdmin = user?.role == 'admin';
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role ENUM('user', 'admin') DEFAULT 'user',
  avatar VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Default Admin Account:**
- Email: `admin@renthome.com`
- Password: `adminpassword123`
- Role: `admin`

**Regular User Accounts:**
- All new registrations default to `role = 'user'`
- Cannot be changed through the app interface
- Must be manually updated in database by system administrator

## Security Summary

### ✅ What Regular Users CAN Do:
- Browse all properties
- Search and filter properties
- View property details
- Save properties to wishlist
- Book properties
- Manage their own profile
- Add/manage payment methods
- Send messages
- View their bookings

### ❌ What Regular Users CANNOT Do:
- Access Admin Dashboard
- Create new properties
- Edit any property
- Delete any property
- Change their role to admin
- Access admin-only API endpoints

### ✅ What Admins CAN Do:
- Everything regular users can do, PLUS:
- Access Admin Dashboard
- Create new properties
- Edit any property
- Delete any property
- View edit/delete buttons on property cards

## Testing Role-Based Access

### Test as Regular User:
1. Register a new account or login as non-admin
2. Navigate to Profile tab
3. Verify "Admin Dashboard" option is NOT visible
4. Go to Explore tab
5. Verify edit/delete icons are NOT visible on property cards
6. Attempt direct API call to create property (should return 403 Forbidden)

### Test as Admin:
1. Login as `admin@renthome.com`
2. Navigate to Profile tab
3. Verify "Admin Dashboard" option IS visible
4. Go to Explore tab
5. Verify edit/delete icons ARE visible on property cards
6. Test creating, editing, and deleting properties

## API Error Responses

### Unauthorized (No Token)
```json
{
  "message": "Not authorized, no token"
}
```
Status Code: 401

### Forbidden (Not Admin)
```json
{
  "message": "Not authorized as admin"
}
```
Status Code: 403

### Invalid Token
```json
{
  "message": "Not authorized, token failed"
}
```
Status Code: 401

## Recommendations for Production

1. **Change Default Admin Password**
   - Update admin password immediately after deployment
   - Use strong, unique password

2. **Implement Password Reset**
   - Add email-based password reset functionality
   - Require strong passwords (min 8 chars, mixed case, numbers)

3. **Add Activity Logging**
   - Log all admin actions (create, update, delete)
   - Track who made changes and when

4. **Rate Limiting**
   - Implement rate limiting on API endpoints
   - Prevent brute force attacks

5. **HTTPS Only**
   - Enforce HTTPS in production
   - Secure all API communications

6. **Token Expiration**
   - Consider implementing token refresh mechanism
   - Set appropriate token expiration times

## Conclusion

The RentHome application implements comprehensive role-based access control at both the backend (API) and frontend (UI) levels. Regular users are completely restricted from performing any administrative actions related to property management, ensuring data integrity and security.
