# Contributing

HairBooking Studio Pro is an academic and portfolio project. Contributions should keep the codebase understandable, demo-friendly and aligned with the thesis scope.

## Local Setup

1. Open `HairBooking.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Build and run the `HairBooking` scheme.

For a lightweight terminal check, run:

```bash
swiftc -typecheck HairBooking/Models.swift HairBooking/BookingStore.swift HairBooking/SharedViews.swift HairBooking/ContentView.swift HairBooking/HairBookingApp.swift
```

## Development Guidelines

- Keep domain logic in `BookingStore.swift` or dedicated model helpers.
- Keep reusable UI components in `SharedViews.swift`.
- Keep feature screens small and readable.
- Add documentation when changing behavior that matters for the thesis or portfolio.
- Avoid committing Xcode user state, local generated files or unrelated projects.

## Commit Style

Use short imperative commit messages:

```text
Add weekly workload forecast
Extract shared SwiftUI components
Fix booking validation
```

## Pull Request Checklist

- The app typechecks locally.
- The affected workflow has been tested manually in the simulator when possible.
- README or docs are updated if user-visible behavior changed.
- The change is scoped to HairBooking and does not include unrelated local folders.
