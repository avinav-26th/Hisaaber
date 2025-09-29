# Hisaaber - हिसाबer

A smart digital ledger app for shopkeepers, designed to quickly calculate totals from handwritten bills using the power of OCR.

---

## 📜 Project Description

Hisaaber solves the daily hassle for shopkeepers of manually calculating the total bill amount for each customer from handwritten lists. This process is time-consuming, prone to errors, and can lead to a poor customer experience.

This app allows a shopkeeper to simply take a picture of an item-price list. Using a powerful cloud-based OCR engine, it recognizes the text, parses the items and prices, and calculates the gross total in seconds. Each bill is saved locally for fast, offline access and can be synced to the cloud for backup.

## ✨ Key Features

* **📷 Scan & Calculate:** Instantly calculate bill totals by taking a picture of a handwritten or printed list.
* **🤖 AI-Powered OCR:** Utilizes a powerful cloud-based OCR service (OCR.space) for high accuracy on various text types.
* **🖼️ Image Pre-processing:** Includes in-app tools to crop and automatically clean up images (deskewing, binarization) to maximize recognition accuracy.
* **💾 Offline First:** All bills and user data are saved to a local on-device database (Hive) for instant access, even without an internet connection.
* **👤 User Profiles:** Simple user profiles with customizable names and avatars.
* **📜 Detailed History:** A complete, searchable history of all past transactions.
* **📌 Pin & Dismiss:** Users can pin important bills to the top of their recent list and swipe to hide others.
* **🔄 Pull-to-Refresh:** A familiar pull-to-refresh gesture on the home screen to update the list.

<!-- 
## 📱 App Screenshots

| Splash Screen      | Login Screen       | Home Screen        |
| :----------------: | :----------------: | :----------------: |
| *[Add Screenshot]* | *[Add Screenshot]* | *[Add Screenshot]* |
|     **Scanner** | **Image Confirmation** | **Total & Naming** |
| *[Add Screenshot]* | *[Add Screenshot]* | *[Add Screenshot]* |
|     **History** |   **Bill Details** |   **Edit Profile** |
| *[Add Screenshot]* | *[Add Screenshot]* | *[Add Screenshot]* |
-->

## 💻 Tech Stack & Packages

* **Framework:** Flutter
* **State Management:** Provider
* **Local Database:** Hive
* **Backend Services:**
    * Firebase (Firestore for cloud backup)
    * Dummy Phone Authentication (simulated locally)
* **OCR Service:** OCR.space API & Google ML Kit
* **Key Packages:**
    * `camera`: For the custom camera interface.
    * `image_cropper`: For cropping captured images.
    * `image`: For advanced image pre-processing.
    * `http`: For making API calls to the OCR service.
    * `google_ml_kit`: For the back-up OCR function
    * `pinput`: For the styled OTP input field.
    * `flutter_native_splash`: For the native splash screen.
    * `flutter_launcher_icons`: For generating the app launcher icon.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed.
* An editor like VS Code or Android Studio.
* A physical device or emulator for testing.

### Installation

1.  **Clone the repo**
    ```sh
    git clone [https://github.com/your_username/hisaaber.git](https://github.com/your_username/hisaaber.git)
    ```
2.  **Install packages**
    ```sh
    flutter pub get
    ```
3.  **Set up Firebase** (Optional, for cloud sync)
    * Create a Firebase project.
    * Register a new Android/iOS app with your package name (e.g., `com.yourcompany.hisaaber`).
    * Download the `google-services.json` (for Android) and place it in the `android/app/` directory.
    * Run `flutterfire configure` to generate the `firebase_options.dart` file.
    * Enable the **Cloud Firestore** API in your Google Cloud console.

4.  **Get an OCR API Key**
    * Go to [https://ocr.space/](https://ocr.space/) and register for a free API key.
    * Paste your key into the `_apiKey` variable in `lib/api_services/ocr_service.dart`.

5.  **Generate Native Resources**
    * Place your app icon in the `assets` folder and run:
        ```sh
        flutter pub run flutter_launcher_icons
        ```
    * Configure your native splash screen in `pubspec.yaml` and run:
        ```sh
        flutter pub run flutter_native_splash:create
        ```

6.  **Run the App**
    ```sh
    flutter run
    ```

---

### Disclosure
For the current project version, it cannot provide results with 100% accuracy, because the good OCR models (like the Google Vision API) are paid features and due to budget issues, other less accurate OCR services have been used.
