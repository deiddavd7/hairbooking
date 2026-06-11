# Release Checklist

Use this checklist before tagging a public milestone.

- Update `CHANGELOG.md`.
- Run Swift typecheck.
- Run XCTest from Xcode or `xcodebuild test`.
- Open the app in the simulator and verify login, booking, clients, Smart desk, Report and Studio settings.
- Check README preview assets.
- Confirm GitHub Actions is passing.
- Create a Git tag.
- Add release notes on GitHub.

Suggested tag format:

```text
v0.6.0
```
