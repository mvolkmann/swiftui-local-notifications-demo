import SwiftUI

struct NotificationsListView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var lnManager: LocalNotificationManager

    var body: some View {
        NavigationView {
            VStack {
                if lnManager.granted {
                    scheduleButtons
                    if lnManager.pendingRequests.count > 0 {
                        pendingList
                    }
                    Spacer()
                } else {
                    Button("Enable Notifications") {
                        lnManager.openSettings()
                    }
                }
            }
            .navigationTitle("Local Notifications")
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    Task {
                        await lnManager.updateGranted()
                        await lnManager.updatePendingRequests()
                    }
                }
            }
            .task {
                try? await lnManager.authorize()
            }
            /*
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { lnManager.removeAllRequests() }) {
                        Image(systemName: "clear.fill")
                            .imageScale(.large)
                    }
                }
            }
            */
        }
        .navigationViewStyle(.stack)
        .padding()
    }

    var pendingList: some View {
        GroupBox("Pending Notification Requests") {
            Button("Delete All", role: .destructive) {
                lnManager.removeAllRequests()
            }
            .buttonStyle(.bordered)

            List {
                ForEach(lnManager.pendingRequests, id: \.identifier) { request in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(request.content.title)
                        HStack {
                            Text(request.identifier)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            lnManager.removeRequest(withIdentifier: request.identifier)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle()) // removes top and bottom spacing
        }
    }

    var scheduleButtons: some View {
        GroupBox("Schedule Notifications") {
            Button("Interval") {
                Task {
                    // If repeats is true then timeInterval
                    // must be at least 60 seconds.
                    let notification = LocalNotification(
                        identifier: UUID().uuidString,
                        title: "Some Title",
                        body: "some body",
                        timeInterval: 10,
                        repeats: false
                    )
                    await lnManager.schedule(notification: notification)
                }
            }
            Button("Calendar") {}
            Button("Location") {}
        }
        .buttonStyle(.bordered)
    }
}

struct NotificatoinsListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsListView()
            .environmentObject(LocalNotificationManager())
    }
}
