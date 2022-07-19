//
//  SwiftUIExampleApp.swift
//  SwiftUIExample
//
//  Created by 逸风 on 2022/7/19.
//

import SwiftUI
import UIKit
import JFHeroBrowser

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroNetworkImageProvider.shared
        return true
    }
}

@main
struct SwiftUIExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
