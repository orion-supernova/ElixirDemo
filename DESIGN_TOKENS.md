# 🎨 Design Tokens Reference - Elixir: Daily Ritual

## Color Palette

### Primary Colors
| Token Name | Hex Value | Swift Usage | Purpose |
|------------|-----------|-------------|---------|
| Potion Purple | `#8E44AD` | `Color.potionPurple` | Primary brand, buttons, accents |
| Healing Green | `#2ECC71` | `Color.healingGreen` | Success states, completed doses |
| Mana Blue | `#3498DB` | `Color.manaBlue` | Secondary brand, info states |

### Supporting Colors
| Token Name | Hex Value | Swift Usage | Purpose |
|------------|-----------|-------------|---------|
| Mystic Gold | `#F1C40F` | `Color.mysticGold` | Warnings, pending states, streaks |
| Phoenix Red | `#E74C3C` | `Color.phoenixRed` | Errors, missed doses, alerts |
| Shadow Gray | `#34495E` | `Color.shadowGray` | Neutral, disabled states |
| Cloud White | `#ECF0F1` | `Color.cloudWhite` | Light backgrounds, borders |

### Gradients
| Name | Usage | Code |
|------|-------|------|
| Elixir Gradient | Primary brand gradient | `Color.elixirGradient` |
| Success Gradient | Completion states | `Color.successGradient` |

**Example:**
```swift
Text("Level Up!")
    .foregroundStyle(Color.elixirGradient)
```

---

## Typography Scale

### Font Family
**SF Pro Rounded** - Apple's rounded system font for a friendly, modern feel.

### Type Scale
| Token | Size | Weight | Swift Usage | HTML Equivalent |
|-------|------|--------|-------------|-----------------|
| Large Title | 34pt | Bold | `.ritualLargeTitle` | `<h1>` |
| Title | 28pt | Bold | `.ritualTitle` | `<h2>` |
| Title 2 | 22pt | Semibold | `.ritualTitle2` | `<h3>` |
| Title 3 | 20pt | Semibold | `.ritualTitle3` | `<h4>` |
| Headline | 17pt | Semibold | `.ritualHeadline` | `<h5>` |
| Body | 17pt | Regular | `.ritualBody` | `<p>` |
| Callout | 16pt | Regular | `.ritualCallout` | `<p class="callout">` |
| Subheadline | 15pt | Medium | `.ritualSubheadline` | `<small>` |
| Footnote | 13pt | Regular | `.ritualFootnote` | `<small>` |
| Caption | 12pt | Regular | `.ritualCaption` | `<caption>` |

**Example:**
```swift
Text("Vitamin D")
    .ritualFont(.ritualHeadline)
```

---

## Spacing System

| Token | Value | Swift Usage | Use Case |
|-------|-------|-------------|----------|
| Extra Small | 4pt | `Spacing.xs` | Tight element gaps, icon spacing |
| Small | 8pt | `Spacing.sm` | Related element spacing, padding |
| Medium | 16pt | `Spacing.md` | Default padding, card spacing |
| Large | 24pt | `Spacing.lg` | Section spacing |
| Extra Large | 32pt | `Spacing.xl` | Major section breaks |
| 2X Large | 48pt | `Spacing.xxl` | Screen margins, hero spacing |

**Example:**
```swift
VStack(spacing: Spacing.md) {
    // Content with 16pt spacing
}
.padding(Spacing.lg) // 24pt padding
```

---

## Border Radius

| Size | Value | Use Case |
|------|-------|----------|
| Small | 8pt | Buttons, tags, badges |
| Medium | 12pt | Small cards, inputs |
| Large | 16pt | Cards, containers |
| XLarge | 20pt | Large cards, modals |
| Circle | 50% | Avatars, circular buttons |

**Example:**
```swift
RoundedRectangle(cornerRadius: 16) // Large
```

---

## Shadows

### Default Shadow (Glassmorphism)
```swift
.shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
```

### Elevated Shadow (Cards)
```swift
.shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
```

### Pressed Shadow (Active State)
```swift
.shadow(color: Color.potionPurple.opacity(0.3), radius: 8, x: 0, y: 2)
```

---

## Animation Presets

| Name | Duration | Damping | Swift Usage | Use Case |
|------|----------|---------|-------------|----------|
| Ritual Spring | 0.4s | 0.75 | `.ritualSpring` | Standard interactions |
| Ritual Bounce | 0.5s | 0.6 | `.ritualBounce` | Playful animations |

**Example:**
```swift
withAnimation(.ritualSpring) {
    isVisible.toggle()
}
```

---

## Component Tokens

### Progress Orb
| Property | Value |
|----------|-------|
| Default Size | 220pt |
| Stroke Width | 16pt |
| Background Opacity | 0.15 |
| Gradient | Elixir Gradient |
| Shadow Radius | 8pt |
| Shadow Color | Potion Purple @ 40% |

### Elixir Card
| Property | Value |
|----------|-------|
| Corner Radius | 16pt |
| Padding | `Spacing.md` (16pt) |
| Border Width | 1.5pt |
| Border Gradient | Potion Purple → Mana Blue @ 30% |
| Background | Ultra Thin Material |
| Shadow (Default) | Black @ 8%, 12pt radius |
| Shadow (Pressed) | Potion Purple @ 30%, 8pt radius |

### Glass Card Modifier
| Property | Value |
|----------|-------|
| Material | Ultra Thin Material |
| Border Width | 1pt |
| Border Color | White @ 20% |
| Shadow | Black @ 10%, 10pt radius, y: 5pt |
| Default Corner Radius | 20pt |
| Default Opacity | 0.7 |

---

## Icon System

### SF Symbols Usage

| Category | Common Icons | Color |
|----------|--------------|-------|
| Medications | `pills.fill`, `drop.fill`, `heart.fill`, `sun.max.fill` | Custom per med |
| Status | `checkmark.circle.fill`, `clock.fill`, `xmark.circle.fill`, `exclamationmark.triangle.fill` | Status-based |
| Achievements | `star.fill`, `flame.fill`, `crown.fill`, `medal.fill` | Gold/Red gradient |
| Navigation | `house.fill`, `chart.bar.fill`, `person.circle.fill`, `plus.circle.fill` | Elixir Gradient |

**Icon Sizes:**
- **Small**: 12pt - Status indicators, inline icons
- **Medium**: 20-24pt - Cards, buttons
- **Large**: 32-40pt - Headers, empty states
- **Hero**: 48-60pt - Onboarding, major milestones

---

## Opacity Scale

| Use Case | Opacity | Example |
|----------|---------|---------|
| Disabled | 0.4 | Disabled buttons |
| Subtle | 0.5 | Dividers, hints |
| Medium | 0.7 | Glass effects, overlays |
| Strong | 0.85 | Backgrounds |
| Full | 1.0 | Primary content |

---

## Dose Status Colors

| Status | Color Token | Hex | Icon |
|--------|-------------|-----|------|
| Pending | Mystic Gold | `#F1C40F` | `clock.fill` |
| Taken | Healing Green | `#2ECC71` | `checkmark.circle.fill` |
| Skipped | Gray | `#95A5A6` | `xmark.circle.fill` |
| Missed | Phoenix Red | `#E74C3C` | `exclamationmark.triangle.fill` |

---

## Accessibility Considerations

### Color Contrast
All color combinations meet **WCAG AA** standards:
- Primary text on dark background: 12:1 ratio
- Secondary text on dark background: 7:1 ratio
- Interactive elements: 4.5:1 minimum

### Dynamic Type Support
All `.ritualFont()` sizes scale with accessibility text size settings.

**Example:**
```swift
Text("Important")
    .ritualFont(.ritualHeadline)
    .dynamicTypeSize(.xSmall ... .xxxLarge)
```

### Haptic Feedback
| Interaction | Feedback Style | Implementation |
|-------------|----------------|----------------|
| Button Tap | Medium Impact | `UIImpactFeedbackGenerator(style: .medium)` |
| Success | Success Notification | `UINotificationFeedbackGenerator().notificationOccurred(.success)` |
| Error | Error Notification | `UINotificationFeedbackGenerator().notificationOccurred(.error)` |
| Selection Change | Light Impact | `UIImpactFeedbackGenerator(style: .light)` |

---

## Design Patterns

### Glassmorphism Formula
```swift
content
    .background(.ultraThinMaterial)
    .overlay(RoundedRectangle(cornerRadius: radius).stroke(Color.white.opacity(0.2), lineWidth: 1))
    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
```

### Gradient Text Effect
```swift
Text("Elixir")
    .foregroundStyle(
        LinearGradient(
            colors: [Color.potionPurple, Color.manaBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
```

### Animated Progress Ring
```swift
Circle()
    .trim(from: 0, to: progress)
    .stroke(Color.elixirGradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
    .rotationEffect(.degrees(-90))
    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: progress)
```

---

## Quick Reference Card

### Most Common Patterns

**Card Container:**
```swift
VStack {
    // Content
}
.padding(Spacing.md)
.glassCard()
```

**Primary Button:**
```swift
Button("Action") { }
    .ritualFont(.ritualHeadline)
    .foregroundColor(.white)
    .padding(.horizontal, Spacing.lg)
    .padding(.vertical, Spacing.md)
    .background(Color.elixirGradient)
    .cornerRadius(12)
```

**Status Badge:**
```swift
HStack {
    Image(systemName: "checkmark.circle.fill")
    Text("Complete")
}
.ritualFont(.ritualCallout)
.foregroundColor(.white)
.padding(Spacing.sm)
.background(Color.healingGreen.opacity(0.2))
.cornerRadius(8)
```

---

## Export for Design Tools

### Figma/Sketch Color Variables
```
Brand/Potion Purple: #8E44AD
Brand/Healing Green: #2ECC71
Brand/Mana Blue: #3498DB
Support/Mystic Gold: #F1C40F
Support/Phoenix Red: #E74C3C
Support/Shadow Gray: #34495E
Support/Cloud White: #ECF0F1
```

### CSS Variables (For Web)
```css
:root {
  --color-potion-purple: #8E44AD;
  --color-healing-green: #2ECC71;
  --color-mana-blue: #3498DB;
  --color-mystic-gold: #F1C40F;
  --color-phoenix-red: #E74C3C;
  --color-shadow-gray: #34495E;
  --color-cloud-white: #ECF0F1;

  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-xxl: 48px;

  --font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Rounded', sans-serif;
}
```

---

**Last Updated**: December 31, 2025
**Version**: 1.0 Foundation Release
