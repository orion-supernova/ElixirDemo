# Background Tasks Setup

## Required: Add to Info.plist

You need to add the following entries to your `Info.plist` (or in Xcode target settings under Info):

### Method 1: Using Xcode UI
1. Select your project in Xcode
2. Select the **ElixirDemo** target
3. Go to the **Info** tab
4. Click the **+** button under "Custom iOS Target Properties"
5. Add a new key: `BGTaskSchedulerPermittedIdentifiers`
6. Set type to **Array**
7. Add two items:
   - `com.elixir.refreshNotifications`
   - `com.elixir.deepCleanNotifications`

### Method 2: Direct Info.plist edit
Add this to your Info.plist file:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.elixir.refreshNotifications</string>
    <string>com.elixir.deepCleanNotifications</string>
</array>
```

## How It Works

### 3-Layer Automatic Rescheduling System

#### Layer 1: App Foreground (Most Frequent) ⚡
- Triggers: Every time user opens the app
- Action: Cleans up expired notifications and reschedules
- Frequency: 2-3x per day for health apps
- **Most reliable trigger**

#### Layer 2: BGAppRefreshTask (Daily Background) 🔄
- Identifier: `com.elixir.refreshNotifications`
- Triggers: ~Once per day (iOS decides when)
- Duration: 30 seconds max
- Action: Intelligently checks if rescheduling needed
- **Primary automatic system**

#### Layer 3: BGProcessingTask (Weekly Deep Clean) 🧹
- Identifier: `com.elixir.deepCleanNotifications`
- Triggers: ~Weekly when device idle/charging
- Duration: Several minutes
- Action: Full cleanup and reschedule
- **Deep maintenance**

#### Layer 4: User Interaction (Failsafe) 🆘
- Triggers: Only if BGTask fails for 4-5 days
- Action: Shows notification asking user to tap or open app
- **Backup safety net**

## Testing Background Tasks

### In Simulator/Device (Debug):

```swift
// Add this to your debug menu or settings
#if DEBUG
BackgroundTaskManager.shared.simulateBackgroundRefresh()
#endif
```

### Using Xcode Debugger:

1. Run the app in Xcode
2. Let app go to background (home button)
3. In Xcode debugger console, type:

```bash
# For app refresh task
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.elixir.refreshNotifications"]

# For processing task
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.elixir.deepCleanNotifications"]
```

## Notification Budget Management

The system automatically manages the iOS 64 notification limit:

- **Before**: EOD med could use 60 slots (broken)
- **After**: EOD med uses 7 slots (1 week window)
- **Budget**:
  - Medications: up to 40 slots
  - Water: up to 10 slots
  - Reschedule reminders: 2 slots (failsafe)
  - Buffer: 12 slots

## User Experience

### Normal Case (User Opens App Regularly):
```
Day 1-7: Notifications fire ✅
User opens app → Auto-reschedule ✅
Day 8-14: Fresh notifications ✅
```

### Edge Case (User Inactive):
```
Day 1-7: Notifications fire ✅
Day 8: BGAppRefreshTask runs → Auto-reschedule ✅
Day 8-14: Fresh notifications ✅
Day 15: BGAppRefreshTask runs again → Auto-reschedule ✅
```

### Worst Case (BGTask Fails + User Very Inactive):
```
Day 1-7: Notifications fire ✅
Day 8-12: No reschedule happens ⚠️
Day 13: Only 1 notification left
Day 14: Failsafe notification fires 🆘
User taps "Refresh Reminders" → Manual reschedule ✅
```

## Production Behavior

In production, iOS determines when BGTasks run based on:
- Device usage patterns
- Battery level
- Network connectivity
- Historical app usage

**Expected frequency**:
- `BGAppRefreshTask`: Every 1-2 days
- `BGProcessingTask`: Every 7-14 days

This ensures notifications are always fresh without requiring server infrastructure!
