import SwiftUI

struct NotificationsListView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var lnManager: LocalNotificationManager
    @State private var scheduleDate = Date()

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
            .sheet(item: $lnManager.nextView) { nextView in
                nextView.view()
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

    var calendarBox: some View {
        GroupBox {
            DatePicker("", selection: $scheduleDate).labelsHidden()
            Button("Schedule at Calendar Date/Time") {
                let dateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: scheduleDate
                )
                let notification = LocalNotification(
                    identifier: UUID().uuidString,
                    title: "My Calendar Notification",
                    body: "some body",
                    dateComponents: dateComponents,
                    repeats: false
                )
                Task {
                    await lnManager.schedule(notification: notification)
                }
            }
        }
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
            timeIntervalButton
            calendarBox
            Button("Location") {}
        }
        .buttonStyle(.bordered)
    }

    var timeIntervalButton: some View {
        Button("Schedule After Time Interval") {
            Task {
                // If repeats is true then timeInterval
                // must be at least 60 seconds.
                var notification = LocalNotification(
                    identifier: UUID().uuidString,
                    title: "My Time Interval Notification",
                    body: "some body",
                    timeInterval: 10,
                    repeats: false
                )
                notification.subtitle = "some subtitle"
                // We cannot use the enum value instead of its rawValue.
                notification.userInfo = ["nextView": NextView.promo.rawValue]
                notification.categoryIdentifier = "snooze"

                await lnManager.schedule(notification: notification)
            }
        }
    }
}

struct NotificatoinsListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsListView()
            .environmentObject(LocalNotificationManager())
    }
}
