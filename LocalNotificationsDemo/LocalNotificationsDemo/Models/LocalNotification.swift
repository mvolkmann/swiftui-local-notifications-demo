import Foundation

struct LocalNotification {
    enum ScheduleType {
        case calendar, timeInterval
    }

    var identifier: String
    var title: String
    var subtitle: String?
    var body: String
    var scheduleType: ScheduleType
    var dateComponents: DateComponents?
    var timeInterval: Double? // in seconds
    var repeats: Bool

    // This provides a way to pass data from a tapped notification
    // to the app that created the notification.
    var userInfo: [AnyHashable: Any]?

    // This describes buttons that should appear in a notification
    // when it is long-tapped.
    var categoryIdentifier: String?

    init(
        identifier: String,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool
    ) {
        self.scheduleType = .calendar
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
    }

    init(
        identifier: String,
        title: String,
        body: String,
        timeInterval: Double,
        repeats: Bool
    ) {
        self.scheduleType = .timeInterval
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.dateComponents = nil
        self.repeats = repeats
    }
}
