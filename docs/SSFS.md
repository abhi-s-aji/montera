# Screen-by-Screen Functional Specification (SSFS)
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.  
**Version:** 1.0.0-SSFS  
**Status:** Approved Functional Blueprint  
**Author:** Lead UI/UX Engineer & Technical Product Architect  

---

## 1. Global Interaction Standards & Desktop Shortcuts

### 1.1 Global Keyboard Shortcuts (Desktop Widescreen Layout)
- `Ctrl + N` / `Cmd + N`: Open Quick Add Transaction Modal.
- `Ctrl + F` / `Cmd + F`: Focus Global Search Bar.
- `Ctrl + B` / `Cmd + B`: Toggle Navigation Sidebar Rail.
- `Ctrl + ,` / `Cmd + ,`: Navigate to Settings & Privacy Center.
- `Escape`: Close active Modal Dialog / Dismiss Search focus.
- `Ctrl + Z` / `Cmd + Z`: Trigger Undo for soft-deleted transactions.

### 1.2 Global Touch & Mouse Gestures
- **Swipe Left on Row**: Reveal Delete action button (with haptic vibration).
- **Swipe Right on Row**: Reveal Edit / Category Reassignment action.
- **Double Click Card**: Open detailed inspector pane (Desktop).
- **Long Press Tile**: Open quick contextual action menu (Mobile).

---

## 2. Screen Specifications (Screens 1 – 47)

### 1. Splash Screen
- **Purpose**: Cold startup initializer verifying database integrity and loading secure keys.
- **Entry Points**: App Launch.
- **Exit Points**: Onboarding Screen (first run) or Security Authentication / Dashboard.
- **UI Layout**: Center Monetra logo, app tagline *"Offline. Private. Yours."*, subtle loading pulse.
- **Loading State**: Displays initialization step *"Checking Database Integrity..."*.
- **Error State**: Triggers Recovery Mode if SQLite `quick_check` fails.

### 2. Onboarding Screen
- **Purpose**: Guide new users through privacy values, currency preference, and initial account setup.
- **UI Layout**: Carousel slide presentation (Privacy Guarantee $\rightarrow$ Currency Selection $\rightarrow$ First Account Setup).
- **Interactions**: Next / Skip buttons, currency dropdown selector.
- **State Update**: Creates default `AccountsTable` and `CategoriesTable` records in Drift DB.

### 3. Workspace Dashboard
- **Purpose**: Central command center for overall net worth, MTD spending, and budget velocity.
- **UI Layout**: 3-Column responsive grid (Net Worth StatCard, MTD Income/Expense Cards, Net Worth Chart, Budget Progress Bar, Recent Ledger).
- **Interaction Flow**:
  $$\text{User Opens Dashboard} \rightarrow \text{Load Local DB} \rightarrow \text{Riverpod Calculates Metrics} \rightarrow \text{Animate Canvas Chart}$$

### 4. Quick Add Transaction Modal
- **Purpose**: Fast transaction entry in under 5 seconds.
- **UI Layout**: Compact modal dialog (`TransactionEditorDialog`), Toggle Switch (Expense/Income/Transfer), Amount Field, Description Field, Account Dropdown, Category Dropdown, Tags Field.
- **Validation**: Amount $>0.0$, Non-empty description, Account required.
- **State Update**: `transactionRepositoryProvider.createTransaction()` $\rightarrow$ Updates `AccountsTable.balance` $\rightarrow$ Closes Modal.

### 5. Full Transaction Editor Screen
- **Purpose**: Comprehensive transaction creation and editing with note attachments and metadata.
- **UI Layout**: Multi-section form: Basic Details, Account/Transfer Options, Date/Time Picker, Multi-tag Selector, Notes Area, File Attachment Upload.

### 6. Transaction History Ledger
- **Purpose**: Complete filterable transaction ledger.
- **UI Layout**: Header Search Bar + Category Filter Dropdown + Inline Tag Chips + Virtualized Infinite List grouped by Date.
- **Interactions**: Swipe-to-delete, Row tap opens Transaction Details.

### 7. Transaction Details View
- **Purpose**: Read-only detailed inspection pane for a single transaction.
- **UI Layout**: Amount hero header, Category badge, Account card, Date/Time stamp, Tag list, Notes box, Attachment previewer.

### 8. Global Search Screen
- **Purpose**: Instant full-text search across descriptions, notes, merchants, and tags.
- **UI Layout**: Search input with recent search history chips + FTS5 search result list.
- **Performance**: $<30\text{ms}$ query latency over 100,000 records.

### 9. Advanced Filters Screen
- **Purpose**: Multi-criteria query builder (Date range, Amount bounds, Account list, Category multi-select).
- **UI Layout**: Filter form with slide controls for amount ranges and date pickers.

### 10. Calendar View Screen
- **Purpose**: Monthly calendar grid visualizing daily expenditure totals.
- **UI Layout**: Monthly grid with color-coded daily spending heat dots. Tapping a day opens daily transaction bottom sheet.

### 11. Accounts Overview Screen
- **Purpose**: Card grid displaying all asset and liability financial accounts.
- **UI Layout**: Grid view of `AccountCard` widgets showing account type, icon, color, native currency, and current balance.

### 12. Account Details Screen
- **Purpose**: Single account performance history and filtered ledger.
- **UI Layout**: Account balance header + Account monthly trend line + Account-specific transaction list.

### 13. Transfer Between Accounts Modal
- **Purpose**: Move funds between internal accounts without affecting net worth.
- **UI Layout**: Source Account Dropdown, Destination Account Dropdown, Amount Field, Date Picker, Transfer Category assignment.

### 14. Categories Taxonomy Screen
- **Purpose**: Visual tree manager for income, expense, and transfer categories.
- **UI Layout**: Nested category tree list with color indicators and parent-child expansion toggles.

### 15. Category Editor Dialog
- **Purpose**: Create or edit categories.
- **UI Layout**: Name field, Type selector (Income/Expense/Transfer), Icon Picker, Color Swatch Picker, Parent Category Dropdown.

### 16. Budgets Workspace
- **Purpose**: Manage category spending caps and velocity meters.
- **UI Layout**: Category budget progress bars, spending velocity indicator badges, period selector (Monthly/Yearly).

### 17. Budget Details Screen
- **Purpose**: Deep-dive analytics for a single category budget.
- **UI Layout**: Daily burn rate line graph, days remaining indicator, category transaction breakdown list.

### 18. Savings Goals Screen
- **Purpose**: Track target savings milestones and emergency funds.
- **UI Layout**: Goal milestone circular progress rings, target date projections, allocation status.

### 19. Goal Details Screen
- **Purpose**: Single goal details and linked account balances.
- **UI Layout**: Goal progress bar, linked accounts list, manual contribution logger.

### 20. Analytics Dashboard
- **Purpose**: High-level financial reporting and visual breakdowns.
- **UI Layout**: Income vs. Expense bar graph, Category spending pie chart, Net worth trajectory area chart.

### 21. Cash Flow Analysis Screen
- **Purpose**: Inflow vs. Outflow trend analysis over custom date ranges.
- **UI Layout**: Dual line cashflow comparison chart + Monthly summary table.

### 22. Income vs. Expense Screen
- **Purpose**: Monthly side-by-side comparison of total earnings vs. total expenditures.
- **UI Layout**: Side-by-side bar chart visualization + ratio indicator.

### 23. Category Breakdown Screen
- **Purpose**: Hierarchical spending distribution visualization.
- **UI Layout**: Donut chart + breakdown list with percentage shares.

### 24. Reports Generator Screen
- **Purpose**: Generate exportable PDF and CSV financial summaries.
- **UI Layout**: Report type selector, date range picker, export options, generate button.

### 25. Export Wizard Screen
- **Purpose**: Export raw local database records to JSON/CSV formats.
- **UI Layout**: Format selector (JSON/CSV), Password encryption toggle, File save destination picker.

### 26. Import Wizard Screen
- **Purpose**: Import and reconcile backup files or external CSV ledgers.
- **UI Layout**: File drag-and-drop zone $\rightarrow$ Schema Validation Check $\rightarrow$ Record Reconcile Mode (Merge vs. Overwrite) $\rightarrow$ Execution Progress Bar.

### 27. Backup & Restore Center
- **Purpose**: Manage automated daily local backups and manual restore points.
- **UI Layout**: Backup history list, Create Backup button, Restore File selector.

### 28. Settings Overview Screen
- **Purpose**: Main configuration hub for workspace preferences.
- **UI Layout**: Navigation list: Appearance, Customization, Currency, Security, Backup, About.

### 29. Appearance Settings Screen
- **Purpose**: Toggle theme modes (Light, Dark, OLED Pitch Black).
- **UI Layout**: Theme mode selection radio cards + Live preview container.

### 30. Customization Center Screen
- **Purpose**: Adjust UI density, corner radiuses, and font family settings.
- **UI Layout**: Corner Radius Slider ($4\text{px} - 24\text{px}$), Density Radio, Font Dropdown.

### 31. Theme Editor Screen
- **Purpose**: Pick primary accent color hex codes.
- **UI Layout**: Palette grid swatches (Indigo, Emerald, Rose, Amber, Cyan, Purple) + Custom Hex input.

### 32. Dashboard Layout Editor
- **Purpose**: Drag-and-drop custom widget ordering on the workspace dashboard.
- **UI Layout**: Reorderable widget list with visibility toggles.

### 33. Chart Customization Screen
- **Purpose**: Customize line graph styles, smooth interpolation curves, and gradient fills.
- **UI Layout**: Smooth curve toggle, gradient opacity slider, chart height selector.

### 34. Currency Settings Screen
- **Purpose**: Set base workspace currency and manage multi-currency exchange rates.
- **UI Layout**: Base currency dropdown (USD, EUR, GBP, INR, JPY) + Exchange rates manual table.

### 35. Security & Vault Screen
- **Purpose**: Configure database encryption, PIN lock, and biometric authentication.
- **UI Layout**: Security Lock Toggle, PIN Setup trigger, Biometrics toggle, Auto-lock duration dropdown.

### 36. PIN Setup Screen
- **Purpose**: Set up 4-digit or 6-digit local security access PIN.
- **UI Layout**: Keypad pin input view with confirmation step.

### 37. Biometric Authentication Screen
- **Purpose**: Screen lock gatekeeper requiring Fingerprint / FaceID / PIN on app resume.
- **UI Layout**: App lock shield logo + "Tap to Unlock" biometric trigger button.

### 38. About Monetra Screen
- **Purpose**: Display version metadata, open-source license info, and philosophy statement.
- **UI Layout**: Monetra logo, Version 1.0.0, Core Values summary, GitHub link.

### 39. Open Source Licenses Screen
- **Purpose**: Credit open-source Flutter packages and SQLite libraries.
- **UI Layout**: Scrollable open-source package licenses list (`LicensePage`).

### 40. Plugin Manager Screen
- **Purpose**: Manage sandbox community plugins (Import parsers, custom report generators).
- **UI Layout**: Installed plugins list, Enable/Disable toggles, Permissions inspector.

### 41. Notification Center Screen
- **Purpose**: Review local in-app alert logs (Budget limit warnings, goal completions, daily backup confirmations).
- **UI Layout**: Chronological notification alert tiles list with clear all trigger.

### 42. Help & Documentation Screen
- **Purpose**: Offline searchable user manual and keyboard shortcut reference card.
- **UI Layout**: Searchable help topic list + Keyboard shortcut cheat sheet modal.

### 43. System Error Screen
- **Purpose**: Fallback error screen displaying crash traces safely without data loss.
- **UI Layout**: Warning icon, user-friendly failure notice, Masked error details fold, Restart App button.

### 44. Empty States View Specifications
- **Purpose**: Reusable empty state view pattern for screens with 0 records.
- **UI Layout**: Centered vector icon ($48\text{px}$), Title text, Friendly guidance note, Primary call-to-action button.

### 45. Permission Request Screen
- **Purpose**: Prompt user for local file system access permissions when exporting backups.
- **UI Layout**: Permission shield graphic, explanation note, Grant Access button.

### 46. Maintenance Mode Screen
- **Purpose**: Displayed during schema migrations or database WAL optimization checkpoints.
- **UI Layout**: "Optimizing Local Storage..." message + smooth progress bar.

### 47. Database Recovery Mode Screen
- **Purpose**: Displayed if SQLite corruption is detected on boot.
- **UI Layout**: Warning notice, Repair Database button, Restore Daily JSON Backup button.

---

## 3. System Notification Specifications

### N-01: Budget Limit Exceeded
- **Trigger**: Transaction creation causes category spending to exceed $100\%$ of budget limit.
- **Visual Style**: Amber/Red banner alert with sound/vibration feedback.
- **Action**: Tap opens Budget Details Screen (#17).

### N-02: Goal Milestone Completed
- **Trigger**: Linked account sum reaches $100\%$ of Goal target amount.
- **Visual Style**: Celebration green toast notification.
- **Action**: Tap opens Goal Details Screen (#19).

### N-03: Daily Backup Completed
- **Trigger**: Automated local daily JSON backup successfully written to disk.
- **Visual Style**: Quiet green check toast ($2.0\text{s}$ display).

---

## 4. Modal Confirmation Dialog Specifications

### D-01: Delete Transaction Confirmation
- **Trigger**: User taps delete action on transaction details or swipes ledger row.
- **Content**: *"Are you sure you want to delete 'Whole Foods Groceries' (\$142.80)? This action can be undone from the toast notification."*
- **Buttons**: `Cancel` (Ghost), `Delete` (Danger Red).

### D-02: Erase All Local Workspace Data
- **Trigger**: User taps "Erase All Data" in Security Settings.
- **Content**: *"CAUTION: This will permanently wipe all local database files, accounts, categories, and settings from this device. Type 'ERASE' to confirm."*
- **Buttons**: `Cancel` (Ghost), `Permanently Wipe Data` (Disabled until 'ERASE' typed).
