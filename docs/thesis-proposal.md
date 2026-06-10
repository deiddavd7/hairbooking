# Thesis Proposal

## Title

Design and development of a mobile booking management system with operational decision support for small professional studios.

## Context

Small professional studios such as hair salons, tattoo studios, beauty centers and freelance service providers often manage appointments through fragmented tools: messaging apps, paper agendas, spreadsheets and generic calendars. This creates duplicated information, missed reminders, limited visibility over workload and difficulty analyzing business performance.

HairBooking Studio Pro addresses this problem with a mobile-first management system focused on bookings, clients, staff availability, payments and operational insights.

## Objective

The goal of the thesis is to design, implement and evaluate a software prototype that supports the daily operations of appointment-based studios while providing a foundation for future cloud synchronization and predictive analytics.

## Research Questions

- How can a mobile application model the main operational processes of a small booking-based studio?
- How can scheduling conflicts be detected reliably using local domain logic?
- Which metrics are useful for supporting daily management decisions?
- How can the architecture be prepared for a later transition from local persistence to a remote backend?
- Which data could support future predictive models for no-show risk, demand peaks and slot optimization?

## Functional Requirements

- Staff login flow
- Onboarding flow
- Booking creation, editing and status management
- Client registry and client history
- Service catalog with duration and price
- Staff management with role and specialty
- Availability rules per weekday
- Conflict detection by professional and time interval
- Local notification scheduling
- Dashboard metrics
- JSON backup export
- Smart slot suggestions

## Non-Functional Requirements

- Usable mobile interface
- Clear separation between domain models, state management and presentation
- Local-first behavior
- Deterministic data export
- Extensibility toward backend synchronization
- Maintainable codebase suitable for public GitHub review

## Methodology

1. Requirements analysis for appointment-based studios.
2. Domain modeling of clients, services, staff, bookings and availability.
3. SwiftUI prototype implementation.
4. Local persistence and backup strategy.
5. Scheduling and conflict detection logic.
6. Dashboard and operational insight design.
7. Evaluation through scenarios and test cases.
8. Definition of cloud and analytics roadmap.

## Expected Outcome

The final result is a working iOS prototype supported by technical documentation, architecture diagrams, use cases, implementation notes and a roadmap for production deployment.
