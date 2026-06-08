# RemoteRecruit

RemoteRecruit is a SwiftUI‑based iOS application that allows users to browse and search for job listings. The app demonstrates a clean architecture with a clear separation of concerns:

* **Networking** – `NetworkClient` handles all HTTP requests, retry logic, and error mapping.
* **Domain** – `JobService` fetches jobs from the API and exposes a simple protocol for testability.
* **Presentation** – `JobListViewModel` manages UI state, debounced search, and pagination.
* **UI** – SwiftUI views (`JobsListView`, `JobDetailView`) consume the view model.

## How It Works

1. **App Launch** – The `SceneDelegate` creates a `UIHostingController` with the root SwiftUI view.
2. **Fetching Jobs** – `JobListViewModel` calls `JobService.fetchJobs()` on init. The service uses `NetworkClient` to request the `/jobs` endpoint and decodes the response into `[Jobs]`.
3. **Displaying Jobs** – The view model publishes a `JobListViewState` (`loading`, `empty`, `loaded`, `error`). The SwiftUI view reacts to this state and shows a list, a loading indicator, or an error message.
4. **Searching** – When the user types in the search bar, the view model debounces the input (300 ms) and filters the cached jobs locally. The filtered results are published back to the UI.
5. **Pull‑to‑Refresh** – The view model exposes a `refresh()` method that re‑fetches jobs from the network.

## Running the Tests

The project includes unit tests for both the service layer and the view model. To run the tests:

```bash
xcodebuild test -scheme RemoteRecruit -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

The tests use a `MockNetworkClient` to simulate network responses and verify that the view model behaves correctly for loading, empty, and error states.

## Extending the App

* **Pagination** – The current implementation loads all jobs at once. To add pagination, modify `JobService` to accept page parameters and update the view model to request subsequent pages.
* **Caching** – Persist jobs locally (e.g., Core Data or UserDefaults) to provide offline support.
* **Error Handling** – Enhance `AppError` mapping to show user‑friendly messages.

## License

MIT License – see the `LICENSE` file for details.
