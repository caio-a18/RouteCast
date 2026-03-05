# Final Project Proposal
## Routecast: Weather Along Your Route

### Project Overview
**Routecast** is an iOS application that shows users the weather conditions they will experience at each point along their journey, not just at their destination. A user enters a starting point and a destination, selects a travel mode, and sets a departure time. The app plots the route using **Apple MapKit** and `MKDirections`, then samples a series of coordinates at regular intervals along the polyline. 

For each checkpoint, it calculates the estimated time of arrival based on the selected travel mode and uses that timestamp to call the **OpenWeatherMap** forecast API with the checkpoint coordinates. This means the weather shown at each point reflects what conditions will actually be like when the user passes through, not what the weather is right now.

Routecast supports four travel modes: driving, walking, cycling, and public transit. Each mode uses a different average speed to calculate checkpoint arrival times, ensuring the forecast is accurate for how the user is actually travelling. Users can optionally save frequently used routes, stored locally on device using **SwiftData** and loadable instantly from a saved routes screen without re-entering origin and destination.

---

### Technical Implementation

1.  **Tech Stack:**
    * **Frontend:** SwiftUI and Swift for data utilities and on-device processing.
    * **Backend:** Python FastAPI for data processing and formatting.
    * **Deployment:** HTTP and SSE web service on Vercel. We are choosing to go with **SSE (Server-Sent Events)** for weather updates to avoid HTTP polling and instantly get weather updates as soon as the server has them. HTTP endpoints will be made available in case a user wants to request additional metadata regarding the weather in their current area.
2.  **Routing and maps:** Apple MapKit and `MKDirections` for route calculation and polyline rendering at no cost, no API key required.
3.  **Weather data:** OpenWeatherMap forecast API free tier provides 1,000 calls per day, which is more than sufficient for development and demo use.
4.  **Persistence:** **SwiftData** for optionally saving and loading user routes locally on device.
5.  **Networking:** Swift async/await with proper error handling for all API calls, with user-facing error states shown in the UI.
    * **Offline:** If a user is offline and/or internet connection is lost, the app will use the `ContentUnavailableView` to notify the user that there is an error instead of seeing an empty map or a spinner loader indefinitely.
    * **Invalid Route:** There is no polyline to drive from Cleveland to London, so the app will catch the error and present an alert or overlay informing the user that the route is not possible.
    * **API Errors:** Handling 429 (Rate limit) and 500 (Server errors).
6.  **Logo and Custom Styling:** A custom logo and UI animations when applicable (for example, weather icons popping in).

---

### Team
**Name:** Krupp's Disciples  
**Members:** Sophia Kager, Vinlaw Mudhewe, Caio Albuquerque, Chiebuka Onyejesi

---

### Suggestions:
- https://developer.apple.com/documentation/Charts
