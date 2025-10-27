//
//  AppDelegate.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import UIKit
import ZFPlayer
import SJBaseVideoPlayer
import Alamofire
import CoreTelephony
import SystemConfiguration

let NetworkChange: NSNotification.Name = NSNotification.Name(rawValue: "networkChangeNotification")

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func networkMonitor() {
        NetworkReachabilityManager.default?.startListening(onQueue: DispatchQueue.main, onUpdatePerforming: { status in
            let network = NetworkReachabilityManager.networkType(status: status)
            NotificationCenter.default.post(name: NetworkChange, object: nil, userInfo: ["network": network])
        })
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let window = window as? SJRotationFullscreenWindow, let manager = window.rotationManager {
            return manager.supportedInterfaceOrientations(for: window)
        }
        
        let gk_orientationMask = GKRotationManager.supportedInterfaceOrientation(for: window)
        if gk_orientationMask != .unknown {
            return UIInterfaceOrientationMask(rawValue: gk_orientationMask.rawValue)
        }
        
        let orientationMask = ZFLandscapeRotationManager.supportedInterfaceOrientations(for: window)
        if orientationMask != ZFInterfaceOrientationMask(rawValue: 0) {
            return UIInterfaceOrientationMask(rawValue: orientationMask.rawValue)
        }
        
        return .portrait
    }
    
}

extension NetworkReachabilityManager {
    private static var notReachable: String {
        "无网络"
    }
    
    // 获取蜂窝网络类型
    private static func cellularType() -> String {
        let info = CTTelephonyNetworkInfo()
        var status: String
        if #available(iOS 12.0, *) {
            guard let dict = info.serviceCurrentRadioAccessTechnology, let firstKey = dict.keys.first, let statusTemp = dict[firstKey] else { return notReachable }
            status = statusTemp
        }else {
            guard let statusTemp = info.currentRadioAccessTechnology else { return notReachable }
            status = statusTemp
        }
        if #available(iOS 14.1, *) {
            if status == CTRadioAccessTechnologyNR || status == CTRadioAccessTechnologyNRNSA {
                return "5G"
            }
        }
        switch status {
        case CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyCDMA1x:
            return "2G"
        case CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        default:
            return notReachable
        }
    }
    
    public static func networkType(status: NetworkReachabilityStatus) -> String {
        switch status {
        case .unknown:
            return "未知"
        case .notReachable:
            return notReachable
        case .reachable(let type):
            if type == .ethernetOrWiFi {
                return "WIFI"
            }else {
                return cellularType()
            }
        }
    }
}
