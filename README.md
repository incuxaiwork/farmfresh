# FarmFresh – Multi-Vendor Farm Products E-Commerce Platform

A professional, feature-rich Flutter E-Commerce application designed to connect local farmers directly with customers. This repository houses the main mobile application and an interactive local web simulator to inspect user flows.

---

## 📁 Repository Structure

The project has been cleaned up to focus purely on the mobile application and verification tools:
* **`lib/`**: The core Flutter application source code.
  * **`features/`**: Feature-driven architecture modules:
    * **`authentication/`**: Role-based Login and Signup screens (Customer vs. Farmer).
    * **`home/`**: Main Customer Marketplace storefront and navigation shells.
    * **`products/`**: Detailed product cards, descriptions, ratings, and add-to-cart triggers.
    * **`cart/`**: Checkout summary and pricing calculations.
    * **`orders/`**: Active order tracking and verification code (OTP) display.
    * **`farmer/`**: Sales dashboards, real-time product list editing, and client dispatch management.
  * **`routes/`**: GoRouter routing configuration defining the navigation paths.
* **`assets/`**: Global image assets, icons, and illustrations.
* **`simulator/`**: Lightweight web-based mobile simulator board to test Customer, Farmer, Rider, and Admin views locally.

---

## 🚀 Key Features Built

### 1. Customer Marketplace App
* **Storefront**: Browse products by category filters, banner discounts, and farm origins.
* **Product Details**: Complete specifications, calories/nutritional tables, and quick cart staging.
* **Cart & Checkout**: Real-time discount coupon application (`SAVE50`) and automatic delivery charge calculation.
* **Order Tracker**: Live stepper visualizer representing order acceptance, dispatch, and secure confirmation OTP.

### 2. Farmer Partner App
* **Dashboard & Metrics**: Track live total earnings, active inventory count, and pending dispatches.
* **Active catalog editor**: Publish new crop harvests to the market storefront instantly with descriptions, weights, category emojis, and set custom pricing.
* **Inventory Control**: Live catalog management with the ability to delete outdated or out-of-stock items.
* **Order Processing**: View client details, accept requests, and confirm dispatching.

---

## 🛠️ Run the Project Locally

### Option A: Run the Local Web Simulator (Recommended)
If you don't have a local Flutter SDK setup, you can launch the custom mock phone simulator directly in your browser:

1. Open a PowerShell terminal in the repository root.
2. Run the server script:
   ```powershell
   cd simulator
   .\start_server.ps1
   ```
3. Visit the local dashboard in your browser:
   👉 **[http://localhost:8080/](http://localhost:8080/)**

### Option B: Build the Flutter App
Ensure you have the Flutter SDK installed and environment variables configured:

1. Fetch application dependencies:
   ```bash
   flutter pub get
   ```
2. Build or launch on a connected device/emulator:
   ```bash
   flutter run
   ```
