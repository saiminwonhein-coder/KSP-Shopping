# KSP Shopping v2

Bilingual Myanmar/English Flutter demo for Thailand-made drinks, snacks and healthcare products. Prices display in MMK.

## Included
- Myanmar/English language toggle
- MMK product prices and category filters
- Sample product cards
- In-memory shopping cart with quantity controls
- Demo Admin page to add/remove products

## Limitations
This is a front-end demo. Product and cart changes are temporary and reset when the app restarts. Orders are not sent to a server. Secure admin authentication, database storage, inventory sync, delivery workflow and payment integration are not included yet. Medicines are represented as a placeholder category; only appropriately licensed products should be listed and sold.

## Build
Run `flutter pub get` then `flutter build apk --release`.
