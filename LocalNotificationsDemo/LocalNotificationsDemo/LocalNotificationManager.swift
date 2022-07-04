import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var granted = false
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
        content.body = notification.body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: notification.timeInterval,
            repeats: notification.repeats
        )
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

    // This is required by the UNUserNotificationCenterDelegate protocol.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        await updatePendingRequests()
        return [.banner, .sound]
    }
}
