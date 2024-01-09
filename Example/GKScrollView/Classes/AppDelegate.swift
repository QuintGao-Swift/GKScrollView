//
//  AppDelegate.swift
//  GKScrollView
//
//  Created by QuintGao on 08/17/2023.
//  Copyright (c) 2023 QuintGao. All rights reserved.
//

import UIKit
import Alamofire
import CoreTelephony
import SystemConfiguration
import SJBaseVideoPlayer
import ZFPlayer

let NetworkChange: NSNotification.Name = NSNotification.Name(rawValue: "networkChangeNotification")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        networkMonitor()
        
        return true
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
    
    func networkMonitor() {
        NetworkReachabilityManager.default?.startListening(onQueue: DispatchQueue.main, onUpdatePerforming: { status in
            NotificationCenter.default.post(name: NetworkChange, object: nil, userInfo: ["status": status])
        })
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
