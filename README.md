## BudgetBudy

Detects Spendings, Tracks Dues, Simplifies Money Management

---

### Overview

**BudgetBudy** is a personal finance and ledger management app built with **Flutter**.  
It combines:

- a **daily spending tracker** for your own expenses, and
- a **Khatabook‑style party ledger** for tracking who you will give / who you will get money from.

The goal is to make it easy to log transactions quickly, see totals and trends over time, and manage balances with friends, family, or customers — all offline using local storage.

---

### Features

#### Spending Tracker

- Add expenses with **title, amount, date, and category**.
- View spending in multiple time ranges:
  - Daily
  - Weekly
  - Monthly
  - Yearly
- See recent transactions and total spend.
- Data stored locally using **SQLite**, no server required.

#### Khatabook‑Style Party Ledger

- Create **parties** (contacts) with name and phone number.
- Add **“gave”** or **“got”** transactions for each party.
- Automatic calculation of:
  - **You will give** (total amount you owe others)
  - **You will get** (total amount others owe you)
- Party list screen with:
  - Initials avatar and color‑coded tiles
  - Per‑party balance with clear red/green amount

#### Visual Insights & UI

- Clean, modern **Material design** with custom fonts (`OpenSans`, `Quicksand`).
- Basic charts and statistics using `fl_chart` (for spending analytics).
- Drawer with total spending summary.

---

### Tech Stack

- **Framework / UI**

  - Flutter
  - Material Design

- **State Management**

  - `provider`

- **Local Storage / Database**

  - `sqflite`
  - Separate databases for:
    - personal spendings (`spendings.db`)
    - party ledger (`khatabook.db`)

- **Utilities & Libraries**
  - `intl` – date formatting
  - `fl_chart` – charts
  - `random_color` – color utilities
  - `url_launcher` – open external links (if needed)

---

### Project Structure

```text
BudgetBudy/
├── lib/
│   ├── main.dart               # Entry point, theme, routes, Provider setup
│   ├── models/
│   │   ├── transaction.dart    # Personal spending transaction + Transactions provider
│   │   ├── transaction_model.dart  # Party ledger transaction model (gave/got)
│   │   └── party.dart          # Party (contact) model
│   ├── database/
│   │   └── db_helper.dart      # SQLite helper for Khatabook ledger (khatabook.db)
│   ├── DBhelp/
│   │   └── dbhelper.dart       # SQLite helper for personal spendings (spendings.db)
│   ├── screens/
│   │   ├── home_screen.dart           # Tabbed view (Daily/Weekly/Monthly/Yearly)
│   │   ├── new_transaction.dart       # Add new personal spending
│   │   ├── party_list_screen.dart     # Parties list + summary (You will give/get)
│   │   ├── party_profile_screen.dart  # Per‑party details and transactions
│   │   └── statistics/…               # Statistics / analytics views
│   └── widgets/
│       ├── app_drawer.dart            # Drawer with totals, navigation
│       ├── transaction_tile.dart      # UI for individual transactions
│       ├── no_trancaction.dart        # Empty state widget
│       └── pie_chart_widgets/…        # Chart widgets using fl_chart
├── assets/
│   ├── fonts/                         # OpenSans, Quicksand
│   └── images/                        # App icon, illustrations
├── pubspec.yaml                       # Dependencies and assets configuration
└── README.md                          # Project documentation (this file)
```

---

### Getting Started

#### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/BudgetBudy.git
cd BudgetBudy
```

#### 2. Install Dependencies

Make sure Flutter is installed and configured:

```bash
flutter doctor
```

Then install project dependencies:

```bash
flutter pub get
```

#### 3. Run the Application

```bash
flutter run
```

Select your device/emulator when prompted.  
The app will start with the **Home** screen (spending tabs). You can navigate to the Khatabook ledger from the drawer or dedicated navigation option (depending on your UI).

---

### Model & Data Layer (High Level)

#### Personal Spending (`Transaction` / `Transactions`)

- `Transaction` model:
  - `id`, `title`, `amount`, `date`, `category`
- `Transactions` provider:
  - Stores a list of transactions in memory.
  - Persists data via `DBhelp/dbhelper.dart` into `spendings.db`.
  - Provides:
    - `addTransactions`, `deleteTransaction`, `fetchTransactions`
    - Filters: daily, weekly, monthly, yearly, recent
    - Aggregations for charts and totals

#### Party Ledger (`Party`, `TransactionModel`)

- `Party`:
  - `id`, `name`, `phone`
- `TransactionModel`:
  - `id?`, `partyId`, `amount`, `type (gave/got)`, `date`, `note`
- `database/db_helper.dart`:
  - Creates and manages `khatabook.db`
  - Tables:
    - `parties`
    - `transactions` (linked to parties)
  - Provides functions to:
    - Insert/update/delete parties and transactions
    - Compute per‑party balance and totals

---

### Analytics & Visualization

- Time‑based analytics for personal spendings (daily/weekly/monthly/yearly).
- Dataset preparation helpers in `Transactions` to compute:
  - Last 6 months / first 6 months totals
  - Recent spendings for charting
- Graphs and charts rendered using `fl_chart` in custom widgets.

---

### Export / Extension Ideas

The current project focuses on core tracking and visualization.  
Some natural extensions you can add on top:

- Export personal transactions or party ledger data as **CSV**.
- Add **PDF summary reports** for a month or a party.
- Add authentication and cloud sync using Firebase.
- Push notifications for due dates or payment reminders.

---

### License

This project is currently provided **as‑is** for personal use and learning.  
You can add a formal license (for example, MIT) if you plan to open‑source it publicly.

---

### Author

Developed by **@devaldaki3**.  
Feel free to:

- open issues for bugs or feature requests
- submit pull requests with improvements
- fork the project and adapt it to your own finance or ledger workflow
