# Global University Search + User Profile App

## Overview

A modern Flutter application that allows users to search for universities worldwide by country, view university details, and see a mock user profile. The app features efficient pagination, local and remote search, country flag display, and robust error handling. It is built using the MVVM architecture, Riverpod for state management, and GoRouter for navigation.

---

## Features

- Search universities by country (with pagination)
- View university details (including website, domains, and country flag)
- Display a mock user profile
- Paginated loading of all universities
- Local search among loaded universities
- Responsive, modern UI with Material 3
- Robust error handling and loading indicators
- Security best practices for API and navigation

---

## Tech Stack

- **Flutter** (Material 3)
- **MVVM Architecture** (Model-View-ViewModel)
- **Riverpod** (State management)
- **GoRouter** (Declarative navigation)
- **HTTP** (API requests)
- **country_flags** (Country flag display)
- **url_launcher** (Open university websites)

---

## Folder Structure

```
lib/
  core/
    theme/                # App themes
    utils/                # Routing and utility functions
  src/
    models/               # Data models (University, UserProfile)
    services/             # API service layer
    viewmodels/           # ViewModels (business logic, controllers)
    providers/            # Riverpod providers
    views/                # Screens (Home, University Detail)
    widgets/              # Reusable widgets (cards, search, lists)
```

---

## Setup Instructions

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd fluttertask
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the app:**

   ```sh
   flutter run
   ```

   > For Android/iOS, ensure you have an emulator or device connected.

4. **Build for release:**
   ```sh
   flutter build apk   # Android
   flutter build ios   # iOS
   ```

---

## Launching the App

- The app launches to the Home screen, showing a user profile and a search bar.
- Enter a country name (e.g., "India", "United States") and tap search.
- Scroll to load more universities (pagination).
- Tap a university to view details and open its website.
- Use the clear (X) button to reset the search and reload all universities.

---

## Security & Error Handling Considerations

- **HTTPS enforced:** All API requests use HTTPS.
- **Input validation:** Search input is trimmed and validated before API calls.
- **Error handling:**
  - Network/API errors are caught and shown to the user.
  - Loading and error states are clearly indicated in the UI.
  - Pagination errors do not crash the app; users can retry.
- **Navigation safety:** GoRouter is used for safe, declarative navigation.
- **URL launching:** URLs are validated and errors are shown if a website cannot be opened.
- **Resource management:** Controllers and listeners are properly disposed to prevent memory leaks.

---

## Screenshots 
<img width="761" height="784" alt="image" src="https://github.com/user-attachments/assets/c2e99cdf-7bd6-45fc-989f-1dda79828f64" />
<img width="760" height="784" alt="image" src="https://github.com/user-attachments/assets/e1b2a778-7ed2-4f01-b916-7f1e74849e4a" />
<img width="332" height="700" alt="image" src="https://github.com/user-attachments/assets/7db07d63-e20a-45f3-9bf8-83d53b5060b6" />
<img width="760" height="784" alt="image" src="https://github.com/user-attachments/assets/6a3ac420-77bb-4a63-bf7f-fd87e171d2dc" />
<img width="761" height="784" alt="image" src="https://github.com/user-attachments/assets/5794d15d-08c9-4bce-bab6-573ad475ee19" />
<img width="761" height="784" alt="image" src="https://github.com/user-attachments/assets/6e591850-99af-4347-9486-d57cc04530ed" />



---

## License

MIT (or your preferred license)
