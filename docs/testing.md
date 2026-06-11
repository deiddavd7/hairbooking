# Testing

HairBooking includes an XCTest target, `HairBookingTests`, focused on domain and store behavior.

## Covered Areas

- booking conflict detection
- overlapping bookings with different professionals
- suggested slots and professional specialties
- service deletion constraints
- report metrics
- no-show risk scoring

## Local Lightweight Check

```bash
swiftc -typecheck HairBooking/Models.swift HairBooking/BookingStore.swift HairBooking/SharedViews.swift HairBooking/ContentView.swift HairBooking/HairBookingApp.swift
```

## Full Xcode Test Run

```bash
xcodebuild -project HairBooking.xcodeproj -scheme HairBooking -destination 'platform=iOS Simulator,name=iPhone 15' clean test
```

If this fails with a Command Line Tools error, open Xcode and select the full Xcode installation from **Xcode > Settings > Locations > Command Line Tools**.

## Continuous Integration

GitHub Actions runs the same `xcodebuild test` command on pushes and pull requests to `main`.
