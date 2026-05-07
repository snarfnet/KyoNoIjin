import SwiftUI
import UserNotifications
import GoogleMobileAds

@main
struct KyoNoIjinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var knowledgeStore = KnowledgeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(knowledgeStore)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
        scheduleDailyNotification()
        return true
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Notification permission: \(granted)")
        }
    }

    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_ijin"])

        let content = UNMutableNotificationContent()
        content.title = "今日の偉人（誕生/没）"
        content.body = "今日生まれた人・亡くなった人をチェック!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_ijin", content: content, trigger: trigger)
        center.add(request)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
