//
//  HabitudeApp.swift
//  Habitude
//
//  Created by Frida Nilsson on 2023-04-17.
//

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          if let error = error {
              print("Error requesting notification authorization: \(error.localizedDescription)")
          }
      }
    FirebaseApp.configure()
    return true
  }
}

@main
struct HabitudeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
