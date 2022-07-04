import SwiftUI

// This is based on the YouTube videos by Stewart Lynch
// at https://www.youtube.com/watch?v=tNaSlfLeCB0.

@main
struct LocalNotificationsDemoApp: App {
    @StateObject var lnManager = LocalNotificationManager()

    var body: some Scene {
        WindowGroup {
            NotificationsListView()
                .environmentObject(lnManager)
        }
    }
}
