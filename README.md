# 🏐 Volleyball Match Tracker — Flutter App

A fully-featured, production-grade volleyball match tracker with real-time court visualization, live scoring, statistics, and fault tracking.

---

## Features

### 🏐 Court Visualization
- Overhead SVG-style court using Flutter's `CustomPainter`
- Attack lines (3-meter dashed), center line, net with grid texture
- 6 color-coded player tokens per team (Setter=gold, Libero=green, MB=purple, OH=blue)
- Flash/glow animation on scoring player token
- Auto clockwise rotation when team earns the serve
- Manual rotation buttons

### 📊 Scoring System
- Best-of-5 match format
- Sets 1–4: first to 25 pts (win by 2)
- Set 5 tie-break: first to 15 pts (win by 2)
- **Deuce logic**: at 24–24 (or 14–14), enters Deuce mode with animated badge
- **Advantage logic**: leading team shows ADV badge; must win by 2
- Animated score numbers (scale pop on score)
- Serving team indicator dot

### 📋 Live Statistics (4 Sidebar Tabs)
1. **LOG** — scrollable point-by-point feed (set, point number, player, type, score)
2. **STATS** — per-player table: Kills, Aces, Blocks, Errors + ⚠ warning badge at 3+ errors
3. **FAULTS** — log service faults, net touches, foot faults, ball handling, positional faults
4. **MATCH** — live timer, sets won, total points, serving team, current rotation chips

### 🎮 Controls
- `+1 TEAM A / +1 TEAM B` score buttons with tap animation
- Point type selector: Kill, Ace, Block, Opponent Error
- Undo last point
- Manual rotation per team
- Substitution dialog (swap player in/out)
- Edit team names
- New Match with confirmation dialog

### 🎨 Design
- Dark sports-dashboard aesthetic (`#0B0F1A` background)
- **Bebas Neue** for display/score typography
- **DM Mono** for stats and data
- Responsive: wide layout (tablet/desktop) side-by-side, narrow layout (phone) tabbed
- Animated deuce/advantage badge (pulse), score pop, player glow flash
- Match won overlay with spring animation

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, fonts, theme
├── models/
│   └── models.dart              # Player, Team, PointRecord, FaultRecord, etc.
├── providers/
│   └── match_provider.dart      # All game state & logic (ChangeNotifier)
├── screens/
│   └── match_screen.dart        # Main screen + layout (wide/narrow)
└── widgets/
    ├── court_widget.dart         # CustomPainter volleyball court
    ├── score_header.dart         # Header with scores, sets, deuce badge
    ├── score_controls.dart       # +1 buttons, point type, undo, rotate
    ├── stats_sidebar.dart        # 4-tab stats panel
    └── match_won_overlay.dart    # Victory screen overlay
```

---

## Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0

### Steps

```bash
# 1. Navigate to project
cd volleyball_tracker

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# 4. Build release APK
flutter build apk --release

# 5. Build for iOS
flutter build ipa
```

### Dependencies
| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management |
| `google_fonts` | ^6.1.0 | Bebas Neue + DM Mono |
| `fl_chart` | ^0.65.0 | Charts (future use) |
| `uuid` | ^4.2.2 | Unique IDs |
| `intl` | ^0.19.0 | Formatting |
| `shared_preferences` | ^2.2.2 | Persistence (future use) |

---

## Extending the App

### Add player names on startup
In `MatchProvider`, update `Team.defaults()` calls or add a setup screen before the match starts.

### Persist match data
Use `shared_preferences` or `sqflite` to save match state. The `MatchProvider` snapshot mechanism is already designed to serialize state easily.

### Add charts
`fl_chart` is included — connect `MatchProvider.pointLog` to a `LineChart` or `BarChart` in the Stats tab.

### Multiple matches / tournament mode
Add a `TournamentProvider` wrapping multiple `MatchProvider` instances.

---

## Screenshots Layout

```
Phone (Portrait)               Tablet (Landscape)
┌─────────────────┐           ┌────────────────────────────┐
│  🏐 VOLLEY      │           │  🏐 VOLLEY TRACKER    [⚙] │
│  [A: 12] [B: 9] │           ├────────────────────────────┤
│  SET 2          │           │             │ LOG STATS ..  │
├─────────────────┤           │   COURT     │               │
│ COURT  │ STATS  │           │   SVG       │ point log...  │
├─────────────────┤           │             │               │
│  [court SVG]    │           │  [controls] │ stats table   │
│  [+1 A] [+1 B]  │           │             │               │
└─────────────────┘           └────────────────────────────┘
```
