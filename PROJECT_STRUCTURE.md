# Elixir: Daily Ritual - Project Structure

## 🏗️ Architecture Overview

This project follows a **strict MVVM + Service Layer** architecture with **Atomic Design** principles for UI components.

```
ElixirDemo/
├── Core/                          # Foundation layer
│   ├── Theme.swift               # Design system (colors, fonts, modifiers)
│   └── Extensions/
│       └── DateExtensions.swift  # Date manipulation helpers
│
├── Data/                         # Data layer
│   └── Models/
│       └── Models.swift          # SwiftData models (Medication, DoseLog, UserStats)
│
├── Services/                     # Business logic layer
│   ├── DataController.swift     # SwiftData container management
│   └── GamificationManager.swift # XP, leveling, streaks, achievements
│
├── ViewModels/                   # Presentation logic layer
│   └── DashboardViewModel.swift # Dashboard business logic
│
└── UI/                           # Presentation layer
    ├── Components/               # Atomic design components
    │   ├── Cards/
    │   │   └── ElixirCard.swift # Medication row component
    │   └── Visuals/
    │       └── ProgressOrb.swift # Circular progress indicator
    │
    └── Screens/                  # Feature screens
        └── DashboardView.swift   # Main dashboard screen
```

---

## 📊 Data Models (SwiftData)

### `Medication`
Represents a medication/supplement with:
- Name, dosage, icon, color
- Frequency settings (daily, twice daily, etc.)
- Scheduled times
- Start/end dates
- One-to-many relationship with `DoseLog`

### `DoseLog`
Tracks individual dose instances with:
- Scheduled time
- Taken time (optional)
- Status (pending, taken, skipped, missed)
- Notes
- Many-to-one relationship with `Medication`

### `UserStats`
Gamification progress tracker with:
- Total XP and current level
- Current/longest streak
- Total doses (taken/skipped/missed)
- Achievement badges
- Completion rate calculations

---

## 🎮 Gamification System

### XP & Leveling
- **+10 XP** per dose taken
- **+50 XP** bonus at 7-day streak
- **+200 XP** bonus at 30-day streak
- Exponential level formula: `XP = (level - 1)² × 50`

### Titles by Level
- **Level 1-5**: Apprentice
- **Level 6-15**: Alchemist
- **Level 16-30**: Master
- **Level 31-50**: Immortal
- **Level 51+**: Legend

### Streak System
- Increments when ALL doses for a day are marked "Taken"
- Resets if any dose is marked "Missed"
- Tracks current streak and longest streak

### Achievements
- Streak milestones (7, 30, 100 days)
- Dose milestones (100, 500 doses)
- Level milestones (10, 25, 50)

---

## 🎨 Design System

### Brand Colors
- **Potion Purple**: `#8E44AD` - Primary brand color
- **Healing Green**: `#2ECC71` - Success states
- **Mana Blue**: `#3498DB` - Secondary brand color
- **Mystic Gold**: `#F1C40F` - Warnings/pending
- **Phoenix Red**: `#E74C3C` - Errors/missed
- **Shadow Gray**: `#34495E` - Neutral
- **Cloud White**: `#ECF0F1` - Light neutral

### Typography
All fonts use **SF Pro Rounded** with semantic naming:
- `.ritualLargeTitle` - 34pt bold
- `.ritualTitle` - 28pt bold
- `.ritualHeadline` - 17pt semibold
- `.ritualBody` - 17pt regular
- `.ritualCallout` - 16pt regular
- `.ritualSubheadline` - 15pt medium
- `.ritualFootnote` - 13pt regular
- `.ritualCaption` - 12pt regular

### View Modifiers
- `.glassCard()` - Glassmorphism effect with ultraThinMaterial
- `.elixirCard()` - High-end card with gradient border
- `.ritualFont()` - Semantic font application
- `hapticFeedback()` - Tactile feedback helper

### Animations
- `.ritualSpring` - Standard spring animation (0.4s, 0.75 damping)
- `.ritualBounce` - Bouncy spring (0.5s, 0.6 damping)

### Spacing System
```swift
Spacing.xs   = 4pt
Spacing.sm   = 8pt
Spacing.md   = 16pt
Spacing.lg   = 24pt
Spacing.xl   = 32pt
Spacing.xxl  = 48pt
```

---

## 🧩 UI Components

### ProgressOrb
**Location**: `UI/Components/Visuals/ProgressOrb.swift`

Displays daily completion progress with:
- Animated circular progress ring
- Percentage display
- Dose count (taken/total)
- Completion icon when 100%
- Gradient stroke effect

**Usage**:
```swift
ProgressOrb(
    progress: 0.75,
    totalDoses: 4,
    takenDoses: 3,
    size: 220
)
```

### ElixirCard
**Location**: `UI/Components/Cards/ElixirCard.swift`

Medication row component with:
- Custom icon with colored background
- Medication name and dosage
- Scheduled time
- Status indicator (checkmark button)
- Glassmorphism styling
- Press animation

**Usage**:
```swift
ElixirCard(
    medication: medication,
    doseLog: doseLog,
    onCheckmarkTapped: {
        // Handle dose status toggle
    }
)
```

### CheckmarkButton
**Location**: Embedded in `ElixirCard.swift`

Status-aware action button with:
- Four states (pending, taken, skipped, missed)
- Color-coded icons
- Haptic feedback
- Scale animation on press

---

## 📱 Screens

### DashboardView
**Location**: `UI/Screens/DashboardView.swift`

Main entry screen featuring:
1. **Header Section**
   - Time-based greeting
   - User level and title
   - Current streak badge

2. **Week Calendar Strip**
   - Horizontal scrollable week view
   - Selected date highlighting
   - Completion status indicators
   - "Today" marker

3. **Progress Orb**
   - Large central progress visualization
   - Completion message when 100%
   - Empty state for no rituals

4. **Stats Summary**
   - Three-card layout
   - Completed/Pending/Missed counts
   - Icon and color-coded

5. **Dose List**
   - Scrollable list of ElixirCards
   - Real-time status updates
   - Empty state with CTA

**ViewModel**: `DashboardViewModel`
- Manages selected date
- Fetches dose logs for selected date
- Calculates progress metrics
- Handles dose status changes
- Manages week calendar data

---

## 🔧 Services

### DataController
**Responsibility**: SwiftData container lifecycle management

**Pattern**: Singleton
```swift
DataController.shared.container
```

**Features**:
- Main container for production
- Preview container with seeded data for SwiftUI previews

### GamificationManager
**Responsibility**: All gamification logic

**Initialization**: Requires `ModelContext`
```swift
GamificationManager(modelContext: context)
```

**Key Methods**:
- `getUserStats()` - Get or create UserStats instance
- `recordDoseTaken(for:)` - Record dose + award XP
- `recordDoseSkipped(for:)` - Record skip (no XP)
- `recordDoseMissed(for:)` - Record miss (no XP)
- `updateDailyStreak(for:)` - Check and update streak
- `getCompletionRateForPeriod(days:)` - Analytics
- `getBestStreakInformation()` - Streak stats

**Achievement System**:
- Automatic achievement checking on XP changes
- Predefined achievement catalog
- Badge storage in UserStats

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- SwiftUI + SwiftData enabled

### Build & Run
1. Open `ElixirDemo.xcodeproj` in Xcode
2. Select an iOS 17+ simulator or device
3. Press `Cmd + R` to build and run

### Initial State
The app starts with:
- Dark mode forced (`.preferredColorScheme(.dark)`)
- Empty database (no medications/doses)
- Level 1 user stats (auto-created on first access)

### Adding Test Data
For development, use the preview container:
```swift
.modelContainer(DataController.preview)
```

This seeds:
- 3 sample medications
- 4 dose logs for today
- User stats with Level 5, 7-day streak

---

## 📝 Next Steps (Future Features)

### Immediate Tasks
1. **Add Ritual Screen** - Form to create new medications
2. **Profile/Stats Screen** - Full gamification dashboard
3. **Notification Manager** - Local push notifications
4. **Edit Medication** - Update existing rituals
5. **History View** - Calendar view of past doses

### Future Enhancements
1. **Widgets** - Lock screen/home screen widgets
2. **Shortcuts Integration** - Siri shortcuts for quick logging
3. **Export Data** - CSV/PDF export
4. **Custom Themes** - User-selectable color schemes
5. **Medication Interactions** - Warning system
6. **Refill Reminders** - Track medication inventory
7. **Health App Integration** - Sync with Apple Health
8. **iCloud Sync** - Multi-device support

---

## 🎯 Code Quality Standards

### File Size Limit
- No view should exceed **100 lines**
- Break complex components into atomic pieces

### SwiftData Best Practices
- Use `@Query` in views for reactive data
- Keep data manipulation (save/delete) in ViewModels
- Use FetchDescriptor with predicates for queries

### Previews
Every view/component must have:
- At least one `#Preview` block
- Use `DataController.preview` for data-dependent views
- Test multiple states (empty, partial, complete)

### Naming Conventions
- **Views**: Descriptive nouns (e.g., `DashboardView`, `ElixirCard`)
- **ViewModels**: Match screen + "ViewModel" (e.g., `DashboardViewModel`)
- **Services**: Manager suffix (e.g., `GamificationManager`)
- **Models**: Singular nouns (e.g., `Medication`, not `Medications`)

### Comments
- Use `// MARK: -` for section organization
- Document complex algorithms
- Self-documenting code > excessive comments

---

## 📄 License
This is a demonstration project for "Elixir: Daily Ritual" - a modern gamified medication tracker.

**Built with**: SwiftUI, SwiftData, iOS 17+
**Architecture**: MVVM + Service Layer
**Design**: Glassmorphism + RPG Gamification
