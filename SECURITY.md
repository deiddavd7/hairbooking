# Security Policy

HairBooking Studio Pro is an academic and portfolio prototype. It currently stores demo data locally through `UserDefaults` and does not include a production backend, real authentication or remote data processing.

## Supported Versions

Only the `main` branch is maintained.

## Reporting A Vulnerability

Please do not open a public issue for sensitive security concerns. Contact the repository owner directly through GitHub instead.

## Current Security Boundaries

- Login is a demo/local flow, not production authentication.
- Cloud synchronization is simulated.
- JSON backup export is local and should not contain real customer data.
- SMS, WhatsApp and email actions use system URL handlers.

## Production Requirements

Before using this app with real customers, add:

- real authentication
- encrypted server-side storage
- transport security
- role-based authorization
- audit logging
- privacy policy and data-retention rules
