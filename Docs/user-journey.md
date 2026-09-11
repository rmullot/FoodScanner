# FoodScanner — screenshots by user journey

Real captures (iPhone 17 Pro simulator), sorted by screen/state of the user journey, light and dark theme side by side. Paths relative to `screenshots/`.

## 1 · Onboarding

First launch, before any camera authorization (`OnboardingView`).

| Light | Dark |
|---|---|
| ![Onboarding light](screenshots/onboarding-light.png) | ![Onboarding dark](screenshots/onboarding-dark.png) |

## 2 · Scanner

Default tab on every subsequent launch (`ScannerScreenView`). A single screen, several states overlaid depending on `model.banner` and `showsKeypad`.

### 2.1 — Idle (no banner, keypad closed)

| Light | Dark |
|---|---|
| ![Scanner idle light](screenshots/scanner-idle-light.png) | ![Scanner idle dark](screenshots/scanner-idle-dark.png) |

### 2.2 — Keypad open, empty field

`FSBarcodeField` shows a sample code as a placeholder; the "Chercher ce produit" button stays disabled (reduced opacity) until a code is entered.

| Light | Dark |
|---|---|
| ![Empty keypad light](screenshots/scanner-keypad-empty-light.png) | ![Empty keypad dark](screenshots/scanner-keypad-empty-dark.png) |

### 2.3 — Keypad, invalid code

Code too short (`65558`): clear button (×) inside the field, inline error message (icon + accent-colored text): "Un code-barres compte entre 8 et 14 chiffres." ("A barcode is between 8 and 14 digits.")

| Light | Dark |
|---|---|
| ![Invalid keypad light](screenshots/scanner-keypad-invalid-light.png) | ![Invalid keypad dark](screenshots/scanner-keypad-invalid-dark.png) |

### 2.4 — Keypad, focused field + "not found" banner

Field with focus (thickened border + cursor), overlaid on the `FSScanStatusBanner(.notFound)` banner left over from the previous scan.

| Light | Dark |
|---|---|
| ![Focused keypad light](screenshots/scanner-keypad-focused-light.png) | ![Focused keypad dark](screenshots/scanner-keypad-focused-dark.png) |

### 2.5 — "Product not found" banner

`FSScanStatusBanner(.notFound)` — orange "?" badge, accent-colored border. "Ce code n'existe pas encore dans la base. Vous pouvez l'ajouter." ("This code isn't in the database yet. You can add it.")

| Light | Dark |
|---|---|
| ![Not found light](screenshots/scanner-notfound-light.png) | ![Not found dark](screenshots/scanner-notfound-dark.png) |

### 2.6 — "Product found" banner

`FSScanStatusBanner(.found)` — green ✓ badge, `fsLeaf` border. Tappable to open the product detail screen.

| Light | Dark |
|---|---|
| ![Found light](screenshots/scanner-found-light.png) | ![Found dark](screenshots/scanner-found-dark.png) |

## 3 · Product detail (Nutriments)

Pushed from the Scanner or History tab (`ProductDetailScreenView`). Two captures per theme: the top of the screen, then the bottom after scrolling (`FSSceneFooter(.laboratory)`, under the floating tab bar).

### 3.1 — Top: product card, Nutri-Score scale, nutrients

| Light | Dark |
|---|---|
| ![Product detail top, light](screenshots/product-detail-light-top.png) | ![Product detail top, dark](screenshots/product-detail-dark-top.png) |

### 3.2 — Bottom: laboratory scene + caption

| Light | Dark |
|---|---|
| ![Product detail bottom, light](screenshots/product-detail-light-footer.png) | ![Product detail bottom, dark](screenshots/product-detail-dark-footer.png) |

## 4 · History

`HistoryScreenView` — list of already-viewed products + `FSSceneFooter(.picnic)`.

### 4.1 — Empty

| Light |
|---|
| ![Empty history](screenshots/history-empty.png) |

### 4.2 — With a viewed product

| Light | Dark |
|---|---|
| ![History light](screenshots/history-list-light.png) | ![History dark](screenshots/history-list-dark.png) |

## 5 · Settings

`SettingsScreenView` — contrast (read-only system status), reduce animations, text size.

| Light | Dark |
|---|---|
| ![Settings light](screenshots/settings-light.png) | ![Settings dark](screenshots/settings-dark.png) |

---

`screenshots/settings-accessibility.png` (09/02) is not included above: it shows an older version of the screen where "Contraste élevé" was an actionable toggle, which no longer matches the current code (read-only system status, see §5). Remove it, or replace it if a new capture is taken in that state.
