# SLCM SWITCH

A mobile application designed to provide a modern, accessible interface for the university's SLCM website. Built using Flutter and FastAPI, this app allows students to view attendance, grades, timetable.

---

## Project Goal

To build a secure, responsive, and user-friendly app that replicates and enhances the functionality of the university's existing SLCM web system, making it more accessible for students and class representatives on mobile devices.

---

##  Installation

### Android
- Download the latest release APK from the [Releases](https://github.com/DK10WS/SLCM_APP/releases) section.
- Install it on your device. Make sure to enable "Install from Unknown Sources" in your settings.

### iOS
- Visit [https://betterslcm.whyredfire.tech](https://betterslcm.whyredfire.tech) in Safari.
- Tap the **Share** icon and select **“Add to Home Screen”** to install it as a Web App.

## Features

-  **Login System**  
  Secure email/password authentication with Student and Parents Login.

-  **Timetable & Calendar View**  
  View your class schedule.

-  **Grades and Attendance**  
  Automatically fetch and display grades, GPA/CGPA, and subject-wise attendance from the SLCM system.

-  **Modern UI**  
  Responsive Flutter UI with dark mode and glassmorphic design for enhanced user experience.

---

## Tech Stack

| Layer         | Technologies                     |
|---------------|----------------------------------|
| **Frontend**  | Flutter, Dart                    |
| **Backend**   | FastAPI (Python)                 |
| **Auth**      | Email & Password (custom logic)  |
| **Deployment**| Docker                           |

---

## Getting Started

### Prerequisites

- Flutter SDK  
- Python 3.9+  
- Docker (optional for deployment)

### Installation

1. **Clone the Repository**

```bash
git clone https://github.com/DK10WS/SLCM_APP.git
cd SLCM_APP
flutter pub get
flutter build apk
```


##  Contributing

We welcome contributions! To get started:

1. **Fork** the repository to your own GitHub account.

2. **Clone** your forked repo and create a new feature branch:
   ```bash
   git checkout -b feature/YourFeatureName

3. Make your changes and commit them with clear messages:

    ``` bash
    git commit -m "Add YourFeatureName"
    ```

4. Push the changes to your GitHub fork:
    ``` bash
    git push origin feature/YourFeatureName
    ```


5 .Open a Pull Request from your branch to the main branch of this repository.
