# HairBooking Studio Pro

HairBooking Studio Pro is an iOS SwiftUI application for managing bookings, clients, services, staff, payments and operational insights for hair salons, tattoo studios and small appointment-based businesses.

The project is designed as a computer engineering thesis and portfolio repository: it demonstrates mobile application architecture, local persistence, domain modeling, conflict detection, scheduling logic, dashboard metrics and a roadmap toward cloud synchronization and predictive analytics.

## Thesis Working Title

**Design and development of a mobile booking management system with operational decision support for small professional studios**

## Core Features

- Staff demo login and onboarding flow
- Multi-operator booking calendar
- Editable staff management with roles, specialties and active status
- Daily agenda and weekly staff schedule
- Client registry with searchable profiles
- Editable client profiles with history and communication actions
- Editable service catalog with prices, durations and professional categories
- Booking creation and editing
- Service catalog for hairdressing and tattoo workflows
- Automatic time conflict detection per operator
- Availability rules, working hours, breaks and closed days
- Deposits, paid amount and remaining balance tracking
- Client history and technical reference notes
- Local notifications before appointments
- Operational dashboard with revenue and completion metrics
- Smart desk with insights, best clients and suggested free slots
- Simulated cloud sync and JSON backup export
- Local persistence through `UserDefaults`

## Technical Stack

- **Language:** Swift
- **UI:** SwiftUI
- **Architecture:** MVVM-inspired state management with an observable store
- **Persistence:** Codable snapshots saved locally
- **Platform:** iOS
- **IDE:** Xcode
- **CI:** GitHub Actions iOS build workflow

## Repository Structure

```text
HairBooking/
  BookingStore.swift      # Application state, persistence and business logic
  ContentView.swift       # SwiftUI screens and reusable UI components
  SharedViews.swift       # Shared UI components, theme and formatting helpers
  Models.swift            # Domain models and sample data
  HairBookingApp.swift    # App entry point
docs/
  architecture.md         # System architecture and design decisions
  thesis-proposal.md      # Thesis framing, goals and research questions
  roadmap.md              # Portfolio and production evolution plan
.github/
  workflows/ios.yml       # GitHub Actions iOS build workflow
```

## Quality And Workflow

- CI build workflow for pushes and pull requests on `main`
- Contribution guidelines in `CONTRIBUTING.md`
- Release history in `CHANGELOG.md`
- GitHub issue and pull request templates

## Engineering Highlights

- Domain entities are modeled with `Codable`, `Identifiable` and `Hashable` value types.
- Booking conflicts are detected by comparing time intervals for the selected professional.
- Suggested slots are generated from availability rules, service duration, breaks and existing bookings.
- Dashboard metrics are computed from the booking dataset without external services.
- No-show risk is estimated with a transparent rule-based score that can evolve into a predictive model.
- Demand is summarized by time segment to support staffing and schedule decisions.
- A dedicated report view summarizes average ticket, completion rate, cancellations and service performance.
- The report view includes a 7-day revenue, workload and capacity utilization forecast.
- The Smart desk highlights inactive clients and provides quick follow-up actions.
- Data export uses a deterministic JSON encoder with ISO 8601 date formatting.
- Notification scheduling is integrated with `UserNotifications`.

## How To Run

1. Open `HairBooking.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Press Run.
4. Use any non-empty email and a password with at least 4 characters.

If `xcodebuild` fails from the terminal because of Command Line Tools, select the full Xcode installation from **Xcode > Settings > Locations > Command Line Tools**.

## Thesis Scope

The current implementation is a complete local prototype. The thesis can evolve it in three directions:

1. **Software engineering:** requirements, domain modeling, architecture, persistence and quality assurance.
2. **Distributed systems:** backend API, authentication, database and cloud synchronization.
3. **Data intelligence:** predictive no-show risk, demand analysis and slot recommendation.

See [docs/thesis-proposal.md](docs/thesis-proposal.md) and [docs/roadmap.md](docs/roadmap.md).

## Production Roadmap

Planned production-grade extensions:

- Backend with REST API or GraphQL
- PostgreSQL database
- Real authentication and role-based authorization
- Cloud synchronization across multiple devices
- Push notifications and email/SMS reminders
- Automated tests and CI with GitHub Actions
- Predictive analytics module for cancellation risk and demand peaks
- Public demo screenshots and App Store-style presentation assets

## Portfolio Checklist

- Clean README with screenshots
- Architecture documentation
- Thesis proposal and technical report
- GitHub Issues or Projects for roadmap tracking
- Tagged releases for major milestones
- Demo video or GIF
- CI badge after adding automated tests

## License

This project is intended for academic and portfolio use. Add a license before publishing the repository publicly.
