import SwiftUI

@main
struct HairBookingApp: App {
    @StateObject private var store = BookingStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
