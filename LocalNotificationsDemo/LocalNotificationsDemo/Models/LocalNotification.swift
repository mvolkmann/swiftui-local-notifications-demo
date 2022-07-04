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
    var userInfo: [AnyHashable: Any]?
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
