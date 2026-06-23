# README.md

FoodScanner is an iOS app (Swift, UIKit) that scans a product barcode (or accepts a typed barcode), fetches nutrition data from the Open Food Facts API (`https://world.openfoodfacts.org/api/v0/product/<barcode>.json`), caches it in Realm, and displays nutrient breakdowns including a pie chart.

- Deployment target: iOS 16.0
- Dependencies are managed via **Swift Package Manager** (resolved by the `FoodScanner.xcodeproj`, not the workspace). This branch (`feature/update_to_spm`) migrated the project off CocoaPods to SPM.
