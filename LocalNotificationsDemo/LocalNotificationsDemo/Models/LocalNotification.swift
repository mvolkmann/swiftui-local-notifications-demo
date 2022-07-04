import Foundation

struct LocalNotification {
    var identifier: String
    var title: String
    var body: String
    var timeInterval: Double // in seconds
    var repeats: Bool
}
