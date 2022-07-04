import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject {
    @Published var granted = false
    @Published var nextView: NextView?
    @Published var pendingRequests: [UNNotificationRequest] = []

    let notificationCenter = UNUserNotificationCenter.current()

    override init() {
        super.init()
        // This allows presenting notifications scheduled by this app
        // while it is in the foreground.
        notificationCenter.delegate = self
    }

    func authorize() async throws {
        try await notificationCenter.requestAuthorization(
            options: [.alert, .badge, .sound]
        )
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }

    func removeAllRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
    }
    
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        if let index = pendingRequests.firstIndex(
            where: { $0.identifier == identifier }
        ) {
            pendingRequests.remove(at: index)
        }
    }

    func schedule(notification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        if let subtitle = notification.subtitle {
            content.subtitle = subtitle
        }
        content.body = notification.body
        content.sound = .default
        if let userInfo = notification.userInfo {
            content.userInfo = userInfo
        }

        let trigger: UNNotificationTrigger!

        switch notification.scheduleType {
        case .calendar:
            guard let dateComponents = notification.dateComponents else { return }
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: notification.repeats
            )

        case .timeInterval:
            guard let timeInterval = notification.timeInterval else { return }
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: notification.repeats
            )
        }

        let request = UNNotificationRequest(
            identifier: notification.identifier,
            content: content,
            trigger: trigger
        )
        try? await notificationCenter.add(request)

        await updatePendingRequests()
    }

    func updateGranted() async {
        let settings = await notificationCenter.notificationSettings()
        granted = settings.authorizationStatus == .authorized
    }

    func updatePendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        await updatePendingRequests()
        return [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let content = response.notification.request.content
        if let value = content.userInfo["nextView"] as? String {
            nextView = NextView(rawValue: value)
        }
    }
}
