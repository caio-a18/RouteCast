// Final Project Proposal

// Routecast: Weather Along Your Route

// Project Overview
// Routecast is an iOS application that shows users the weather conditions they will experience at each point along their journey — not just at their destination.

// A user enters a starting point and a destination, selects a travel mode, and sets a departure time. The app plots the route using Apple MapKit and `MKDirections`, then samples a series of coordinates at regular intervals along the route polyline. For each checkpoint, the app calculates the estimated time of arrival based on the selected travel mode and uses that timestamp to call the OpenWeatherMap forecast API with the checkpoint coordinates. This ensures the weather shown at each point reflects the conditions at the time the user will actually pass through, not just the current conditions.

// Routecast supports four travel modes: driving, walking, cycling, and public transit. Each mode uses a different average speed to calculate checkpoint arrival times, ensuring the forecast is accurate for how the user is actually traveling.

// Users can save frequently used routes, which are stored locally on device using SwiftData. Saved routes can be loaded instantly from a dedicated screen without re-entering origin and destination.

//

// Technical Implementation
// 1. Tech Stack
//    - Frontend: SwiftUI and Swift for on-device processing and data utilities.
//    - Backend: Python FastAPI for data processing and formatting.
//    - Deployment: HTTP and Server-Sent Events (SSE) web service on Vercel. We are choosing SSE for weather updates to avoid HTTP polling and to deliver updates as soon as the server has them. HTTP endpoints will be available for requesting additional metadata about the weather in the user's current area.

// 2. Routing and Maps
//    - Apple MapKit and `MKDirections` for route calculation and polyline rendering at no cost and with no API key required.

// 3. Weather Data
//    - OpenWeatherMap forecast API (free tier provides 1,000 calls per day), which is sufficient for development and demo use.

// 4. Persistence
//    - `SwiftData` for saving and loading user routes locally on device.

// 5. Networking
//    - Swift concurrency (`async/await`) with robust error handling for all API calls, with user-facing error states shown in the UI.
//      - Offline: If a user is offline or the internet connection is lost, the app uses `ContentUnavailableView` to notify the user of the error instead of showing an empty map or an indefinite spinner.
//      - Invalid Route: For impossible routes (e.g., driving from Cleveland to London), the app presents an alert or overlay informing the user that the route is not possible.
//      - API Errors: Handle HTTP 429 (Rate Limit) and 500 (Server Errors) gracefully.

// 6. Logo and Custom Styling
//    - A custom logo and tasteful UI animations (for example, weather icons popping in when updates arrive).

//

// Team
// - Name: Krupp's Disciples
// - Members: Sophia Kager, Vinlaw Mudhewe, Caio Albuquerque, Chiebuka Onyejesi
