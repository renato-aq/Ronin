# Ronin

Ronin is a native Apple app focused on time tracking and monthly revenue estimation for independent contractors working with one or more client companies.

The current project is built as an MVP with local persistence and a simple workflow for daily punch events, company rate management, and historical review.

## Features

- Monthly dashboard with estimated revenue for the current month
- Daily time tracking flow:
  - Entry
  - Lunch break start
  - Lunch break end
  - End of workday
- Company management with hourly rate editing
- Historical records grouped by month
- Manual editing of recorded times
- Swipe-to-delete with confirmation in history
- Local persistence with SwiftData

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- MVVM

## Project Structure

- `Ronin/Models`: SwiftData models
- `Ronin/ViewModels`: presentation state and screen logic
- `Ronin/Views`: SwiftUI screens and components
- `Ronin/Services`: domain/service logic
- `Ronin/Support`: shared formatters and helpers

## Running the App

### Requirements

- Xcode 17+
- iOS Simulator or physical Apple device supported by your local Xcode setup

### Steps

1. Open `Ronin.xcodeproj` in Xcode.
2. Select the `Ronin` scheme.
3. Choose a simulator or connected device.
4. Run the project.

## Notes

- Data is stored locally on device.
- The app does not currently include backend sync, authentication, export, or cloud backup.
- Hourly rate history is preserved by storing the applied rate in each daily record.

## Status

This repository currently contains the MVP foundation and active development work.
