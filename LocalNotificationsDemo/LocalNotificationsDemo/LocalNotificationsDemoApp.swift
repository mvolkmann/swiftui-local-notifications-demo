import SwiftUI

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
