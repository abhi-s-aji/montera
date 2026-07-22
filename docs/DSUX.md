# Monetra Design System & UI/UX Specification (DSUX)
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.  
**Version:** 1.0.0-DSUX  
**Status:** Approved Design Reference  
**Author:** Lead UI/UX Architect & Systems Designer  

---

## 1. Design Philosophy

Monetra's interface is built on **Quiet Confidence**. It rejects the noisy visual paradigms of modern fintech applications—there are no social feeds, gamified streak badges, crypto popups, or aggressive dark-pattern prompts.

### 1.1 Brand Personality & Core UI Attributes
- **Tranquil Efficiency**: Financial management should induce calm, not anxiety. Layouts use generous whitespace, restrained accent colors, and clear visual hierarchy.
- **Immediate Understanding**: Users can determine their total net worth, monthly cashflow status, and budget health within 3 seconds of launching the workspace.
- **Uncompromised Precision**: Numerical figures are formatted with monospace alignment, distinct currency glyphs, and unambiguous sign indicators ($+$ green for income, $-$ neutral/red for expense).
- **Absolute Ownership**: The UI reflects that the data belongs entirely to the user—no app lockups, no forced upgrades, no telemetry indicators.

---

## 2. Design Language

### 2.1 Visual Foundation Rules
- **Minimalism & Whitespace**: Spacing is used as a primary grouping mechanism rather than heavy container borders or distracting divider lines.
- **Rounded Geometry**: Subtle rounded corners ($12\text{px}$ standard radius) establish a modern, approachable feel inspired by Pixel UI and Apple Human Interface Guidelines.
- **Elevation & Flat Surfaces**: Cards use flat surface fills (`Elevation 0`) bounded by thin $1\text{px}$ neutral borders (`BorderSide(color: border.withOpacity(0.4))`). Drop shadows are reserved exclusively for floating modal dialogs and dropdown menus.
- **Subtle Glassmorphism**: Translucent backdrop blur filters ($16\text{px}$ Gaussian blur with $80\%$ surface opacity) applied to persistent floating action bars and sticky navigation headers.

---

## 3. Color System & Dynamic Token Palette

### 3.1 Base Theme Modes

#### Dark Mode (Default Obsidian)
- **Background**: `#090D16` (Obsidian Midnight)
- **Surface**: `#111827` (Dark Slate)
- **Card Fill**: `#1F2937` (Subtle Slate)
- **Border**: `#374151` (Muted Neutral)
- **Text Primary**: `#F9FAFB` (High Contrast White)
- **Text Secondary**: `#9CA3AF` (Muted Gray)

#### OLED Pitch Dark Mode
- **Background**: `#000000` (Pure Black)
- **Surface**: `#0D0D0D`
- **Card Fill**: `#171717`
- **Border**: `#262626`

#### Light Mode (Clean Slate)
- **Background**: `#F8FAFC` (Off-White Porcelain)
- **Surface**: `#FFFFFF` (Pure White)
- **Card Fill**: `#F1F5F9` (Soft Gray)
- **Border**: `#E2E8F0` (Light Border)
- **Text Primary**: `#0F172A` (Deep Slate)
- **Text Secondary**: `#64748B` (Muted Slate)

### 3.2 Financial Status Tokens
- **Income Accent**: `#10B981` (Emerald Green)
- **Expense Neutral**: `#F9FAFB` (Light Text) / `#EF4444` (Rose Red when flagging overspending)
- **Transfer Accent**: `#3B82F6` (Electric Blue)
- **Warning Velocity**: `#F59E0B` (Amber Warning)

### 3.3 Dynamic Theme Customization (Accent Swatches)
Users can select from 6 curated primary accent palettes:
1. **Indigo** (Default): `#6366F1`
2. **Emerald**: `#10B981`
3. **Rose**: `#EC4899`
4. **Amber**: `#F59E0B`
5. **Cyan**: `#06B6D4`
6. **Purple**: `#8B5CF6`

---

## 4. Typography System

### 4.1 Type Hierarchy Specification

| Type Role | Font Family | Size | Weight | Line Height | Tracking | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Display Large** | Outfit | $32\text{px}$ | Bold | $1.2$ | $-0.8\text{px}$ | Net Worth & Page Titles |
| **Title Medium** | Outfit | $18\text{px}$ | SemiBold | $1.3$ | $-0.4\text{px}$ | Section Headers & Card Titles |
| **Body Large** | Inter | $15\text{px}$ | Regular | $1.5$ | $0.0\text{px}$ | Primary Text & Form Fields |
| **Body Medium** | Inter | $13\text{px}$ | Regular | $1.5$ | $0.0\text{px}$ | Subtitles & Descriptions |
| **Numeric Value**| JetBrains Mono| $16\text{px}$ | SemiBold | $1.2$ | $-0.2\text{px}$ | Transaction Amounts & Table Figures |
| **Caption / Tag** | Inter | $11\text{px}$ | Medium | $1.4$ | $+0.2\text{px}$ | Metadata Badges & Timestamps |

---

## 5. Spacing System & Grid Baseline

- **Base Grid**: $4\text{px}$ strict spatial grid. All padding, margins, and component heights are multiples of 4.

$$\text{Spacing Scale} = [4\text{px}, 8\text{px}, 12\text{px}, 16\text{px}, 20\text{px}, 24\text{px}, 32\text{px}, 48\text{px}, 64\text{px}]$$

- **Container Insets**:
  - Screen Padding: $24\text{px}$ (Desktop) / $16\text{px}$ (Mobile).
  - Card Inner Padding: $20\text{px}$ standard.
  - Form Item Spacing: $16\text{px}$ vertical gap.

---

## 6. Shape System & Corner Radius Rules

- **Default Border Radius**: $12\text{px}$ (Customizable via settings slider between $4\text{px}$ sharp and $24\text{px}$ pill-shaped).
- **Cards & Dialogs**: Standard radius ($12\text{px}$).
- **Buttons & Input Fields**: Standard radius ($12\text{px}$).
- **Tags & Status Pills**: Pill radius ($20\text{px}$).
- **Avatars & Category Badges**: Rounded rectangle ($10\text{px}$).

---

## 7. Iconography Principles

- **Style**: Rounded Material Symbols / Cupertino hybrid with consistent $2.0\text{px}$ stroke weights.
- **Icon Sizing**:
  - `Small`: $16\text{px}$ (Inline metadata).
  - `Medium`: $20\text{px}$ (Standard buttons & list items).
  - `Large`: $28\text{px}$ (Feature cards & stat badges).
  - `Hero`: $48\text{px}$ (Empty state illustrations).

---

## 8. Reusable Component Library

### 8.1 Buttons
- **Primary Button**: Filled primary accent background, white bold text, $12\text{px}$ radius, $48\text{px}$ min height. Hover state brightens fill by $10\%$.
- **Secondary / Outlined Button**: $1\text{px}$ neutral border fill, text primary color. Hover state adds $8\%$ primary accent surface overlay.
- **Ghost / Text Button**: Zero border/fill, secondary text color. Used for cancellation actions.

### 8.2 Input Fields & Selection Controls
- **Text & Currency Inputs**: Surface background fill, $1\text{px}$ neutral border, floating label text. Focus state transitions border to $1.5\text{px}$ primary accent.
- **Dropdown Selectors**: Custom popover tile with clear selection indicator checkmarks.

---

## 9. Dashboard Layout Architecture

- **Desktop Layout Grid**: 3-Column responsive layout (Col 1: Key Metric Cards + Quick Actions, Col 2: Net Worth Chart & Cashflow Breakdown, Col 3: Budget Velocity Meters & Recent Ledger).
- **Mobile Layout**: Single column stacked view with sticky quick action floating trigger.

---

## 10. Screen Specifications

### 10.1 Workspace Dashboard
- **Header**: Workspace title, offline status indicator pill, quick "Add Entry" primary trigger button.
- **Top Row**: 3 Stat Cards (Net Worth, Month-to-Date Income, Month-to-Date Expenses).
- **Center Canvas**: Custom Net Worth Trajectory Chart with interactive date range selector (30 Days, YTD, All).
- **Bottom Section**: Recent 5 transactions list with quick edit tap triggers.

### 10.2 Transaction Ledger
- **Header Toolbar**: Multi-field search text field + category filter dropdown + tag quick filter chips.
- **Body**: Infinite scroll virtualized ledger grouped chronologically by day (`Today`, `Yesterday`, `July 20, 2026`).
- **Interaction**: Swipe left on any row to trigger soft-delete with immediate "Undo" snackbar toast.

### 10.3 Settings & Privacy Center
- **Sections**: Theme Appearance (Light/Dark/OLED), Primary Accent Selector (6 color swatches), Radius Slider, Currency Picker, Security Vault Lock, Data Export/Import buttons.

---

## 11. Navigation System Architecture

```text
               +----------------------------------------+
               |        Desktop / Widescreen (>900px)   |
               |   Left Sidebar Rail (220px Fixed)      |
               +----------------------------------------+
                                   │
       ┌───────────────────────────┼───────────────────────────┐
       ▼                           ▼                           ▼
[Dashboard View]         [Transactions View]           [Settings View]
       ▲                           ▲                           ▲
       └───────────────────────────┼───────────────────────────┘
                                   │
               +----------------------------------------+
               |           Mobile Screen (<900px)       |
               |      Bottom Navigation Bar (5 Tabs)    |
               +----------------------------------------+
```

---

## 12. Responsive Breakpoint Specification

- **Compact (Mobile)**: $< 600\text{px}$ width. Single column navigation.
- **Medium (Tablet)**: $600\text{px} - 900\text{px}$ width. Navigation rail + 2-column grid.
- **Expanded (Desktop)**: $> 900\text{px}$ width. Fixed left sidebar ($220\text{px}$) + 3-column dashboard grid.

---

## 13. Motion Design & Animation Principles

- **Purposeful Motion Only**: Animations exist strictly to communicate state transitions (e.g., dialog expanding from trigger button).
- **Transition Durations**:
  - Micro-interactions (Button tap ripple, hover): $150\text{ms}$ (`Curves.easeOut`).
  - Screen transitions (Tab switch, page slide): $250\text{ms}$ (`Curves.fastOutSlowIn`).
  - Modal Dialog Scale/Fade: $200\text{ms}$ (`Curves.easeOutCubic`).
- **Reduced Motion Support**: If OS reduced-motion setting is active, all transition durations are set to $0\text{ms}$ (instant state swaps).

---

## 14. Financial Data Visualization Guidelines

- **Net Worth Line Graph**: Smooth cubic spline curve (`MonetraChart`), $2.5\text{px}$ stroke width, vertical linear gradient fill dropping from $25\%$ accent opacity to $0\%$ opacity at canvas bottom.
- **Budget Progress Meters**: Horizontal rounded progress bar ($10\text{px}$ height). Colors adapt dynamically:
  - $< 80\%$ spent: Primary Accent.
  - $80\% - 100\%$ spent: Amber Warning (`#F59E0B`).
  - $> 100\%$ spent: Rose Red (`#EF4444`).

---

## 15. Accessibility (a11y) Rules

- **WCAG AA / AAA Contrast Compliance**: All body text maintains minimum $4.5:1$ contrast ratio against background surfaces. High-contrast themes maintain $7:1$.
- **Touch Target Size**: Minimum interactive target dimensions of $48\text{px} \times 48\text{px}$ on mobile screens.
- **Focus Indicators**: Visible $2\text{px}$ primary accent focus outline around focused form fields during keyboard navigation.

---

## 16. Customization System Engine

- **Real-Time Token Modulation**: Adjusting the corner radius slider updates `BorderRadius.circular(r)` across all cards, dialogs, inputs, and buttons instantly.
- **Preserving User Aesthetics**: Customized color palettes and typography choices export cleanly alongside JSON backup payloads.

---

## 17. Empty State Patterns

- **Visual Style**: Clean rounded outline vector icon ($48\text{px}$ size), title text, friendly secondary guidance note, and primary action button.
- **Example (No Transactions)**: Icon: `receipt_long_outlined` $\rightarrow$ Title: *"No Transactions Recorded"* $\rightarrow$ Body: *"Log your first expense or income entry to start building your personal financial ledger."* $\rightarrow$ Button: `Add Entry`.

---

## 18. Error State Patterns

- **Validation Error**: Form input fields display inline $12\text{px}$ red text below input container with $1.5\text{px}$ red border.
- **System Failure**: Snackbar toast with dark surface background, warning icon, error explanation, and explicit `Retry` button.

---

## 19. Loading & Skeleton State Patterns

- **Skeleton Loaders**: Subtle pulse animation ($1.5\text{s}$ cycle) over rounded gray containers matching the exact layout geometry of target cards. No plain circular progress spinners on main content screens.

---

## 20. Microinteraction Specifications

- **Button Click**: $2\%$ downward scale pulse on pointer down (`ScaleTransition`).
- **Swipe-to-Delete**: Row slides smoothly with red background revealed; haptic feedback vibration triggered upon threshold cross.
- **Snackbar Undo**: Displayed for $4.0\text{s}$ with progress timer bar allowing immediate single-tap restoration of deleted records.

---

## 21. Accessibility Review Checklist

- [x] All interactive buttons have explicit labels or `Semantics(label: ...)` wrappers.
- [x] Color is never used as the sole indicator of financial state (always paired with $+/-$ text signs or icons).
- [x] Full tab index ordering verified across desktop dialog forms.

---

## 22. UI Consistency Guidelines

1. **Zero Raw Hardcoded Colors**: Always reference `MonetraColors` tokens or `Theme.of(context).colorScheme`.
2. **Standard Padding**: Never use arbitrary padding values like `EdgeInsets.only(top: 13, left: 7)`—use grid multiples ($4, 8, 12, 16, 20, 24$).
3. **No Direct Shadows**: Cards use flat surface fills with neutral borders.

---

## 23. Complete Design Token Table

```json
{
  "token": {
    "spacing": { "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 24, "xxl": 32 },
    "radius": { "small": 6, "default": 12, "pill": 20 },
    "elevation": { "flat": 0, "overlay": 8 },
    "animation": { "fast": 150, "standard": 250, "slow": 400 }
  }
}
```

---

## 24. Future Design Roadmap

- **Version 1.5**: Desktop split-view inspection pane with receipt photo previewer.
- **Version 2.0**: Community theme preset manager with custom JSON theme import/export parser.
