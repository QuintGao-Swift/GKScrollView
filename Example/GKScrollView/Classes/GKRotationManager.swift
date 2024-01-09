//
//  GKRotationManager.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

public struct GKInterfaceOrientationMask: OptionSet, @unchecked Sendable {
    public var rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    public static let unknown: GKInterfaceOrientationMask = GKInterfaceOrientationMask(rawValue: 0)
    public static let portrait: GKInterfaceOrientationMask = GKInterfaceOrientationMask(rawValue: 1 << 0)
    public static let landspaceLeft: GKInterfaceOrientationMask = GKInterfaceOrientationMask(rawValue: 1 << 1)
    public static let landscapeRight: GKInterfaceOrientationMask = GKInterfaceOrientationMask(rawValue: 1 << 2)
    public static let portaitUpsideDown: GKInterfaceOrientationMask = GKInterfaceOrientationMask(rawValue: 1 << 3)
    public static let landscape: GKInterfaceOrientationMask = [.landspaceLeft, landscapeRight]
    public static let all: GKInterfaceOrientationMask = [.portrait, .landscape, .portaitUpsideDown]
    public static let allButUpsideDown: GKInterfaceOrientationMask = [.portrait, .landscape]
}

open class GKRotationManager: NSObject {
    public var window: GKLandscapeWindow?
    public weak var contentView: UIView?
    public weak var containerView: UIView?
    public var allowOrientationRotation: Bool = false {
        didSet {
            if allowOrientationRotation {
                addDeviceOrientationObserver()
            }else {
                removeDeviceOrientationObserver()
            }
        }
    }
    public var isLockedScreen: Bool = false
    public var supportInterfaceOrientation: GKInterfaceOrientationMask = .all
    public var currentOrientation: UIInterfaceOrientation = .portrait
    public private(set) var isFullScreen: Bool = false
    public var orientationWillChange: ((Bool) -> Void)?
    public var orientationDidChanged: ((Bool) -> Void)?
    public var currentDeviceOrientation: UIInterfaceOrientation {
        return UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .portrait
    }
    private var isGeneratingDeviceOrientation: Bool = false
    
    public static var manager: GKRotationManager {
        gkAwake()
        if #available(iOS 16.0, *) {
            return GKRotationManager_iOS_16_Later()
        }else {
            return GKRotationManager_iOS_9_15()
        }
    }
    
    public class func supportedInterfaceOrientation(for window: UIWindow?) -> GKInterfaceOrientationMask {
        if let window = window as? GKLandscapeWindow, let manager = window.rotationManager {
            let orientationMask = manager.supportedInterfaceOrientation(for: window)
            return GKInterfaceOrientationMask(rawValue: orientationMask.rawValue)
        }
        return .unknown
    }
    
    public func rotate() {
        let orientation: UIInterfaceOrientation = currentOrientation == .portrait ? .landscapeRight : .portrait
        rotate(to: orientation, animated: true)
    }
    
    public func rotate(to orientation: UIInterfaceOrientation, animated: Bool) {
        rotate(to: orientation, animated: animated, completion: nil)
    }
    
    public func rotate(to orientation: UIInterfaceOrientation, animated: Bool, completion: (() -> Void)?) {
        self.currentOrientation = orientation
        if UIInterfaceOrientationIsLandscape(orientation) {
            if window == nil {
                window = GKLandscapeWindow(frame: UIScreen.main.bounds)
                window?.rootViewController = landscapeViewController
                window?.rotationManager = self
            }
        }
        self.disableAnimations = !animated
        if Double(UIDevice.current.systemVersion) ?? 0 < 16.0 {
            interface(.unknown, completion: nil)
        }
        interface(orientation, completion: completion)
    }
    
    public func addDeviceOrientationObserver() {
        isGeneratingDeviceOrientation = UIDevice.current.isGeneratingDeviceOrientationNotifications
        if !isGeneratingDeviceOrientation {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    public func removeDeviceOrientationObserver() {
        if !isGeneratingDeviceOrientation {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        window?.isHidden = true
        removeDeviceOrientationObserver()
    }
}

private var disableAnimationsKey: UInt8 = 0
extension GKRotationManager {
    var disableAnimations: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &disableAnimationsKey) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &disableAnimationsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc func supportedInterfaceOrientation(for window: UIWindow) -> UIInterfaceOrientationMask {
        fatalError("You mast override this in a subclass")
    }
    
    func getCurrentOrientation() -> UIInterfaceOrientation {
        if #available(iOS 16.0, *) {
            let list = UIApplication.shared.connectedScenes
            if let scene = list.first as? UIWindowScene {
                return scene.interfaceOrientation
            }else {
                return .portrait
            }
        }else {
            return currentDeviceOrientation
        }
    }
    
    @objc var landscapeViewController: GKLandscapeViewController {
        fatalError("You mast override this in a subclass")
    }
    
    @objc func interface(_ orientation: UIInterfaceOrientation, completion: (() -> Void)?) {
        
    }
    
    @objc func handleDeviceOrientationChange() {
        if !allowOrientationRotation || isLockedScreen { return }
        if !UIDeviceOrientationIsValidInterfaceOrientation(UIDevice.current.orientation) { return }
        let currentOrientation = currentDeviceOrientation
        if currentOrientation == self.currentOrientation { return }
        self.currentOrientation = currentOrientation
        if currentOrientation == .portraitUpsideDown { return }
        switch currentOrientation {
        case .portrait:
            if isSupportPortrait() {
                rotate(to: .portrait, animated: true)
            }
        case .landscapeLeft:
            if isSupportLandscapeLeft() {
                rotate(to: .landscapeLeft, animated: true)
            }
        case .landscapeRight:
            if isSupportLandscapeRight() {
                rotate(to: .landscapeRight, animated: true)
            }
        default:
            break
        }
    }
    
    func isSupport(_ interfaceOrientation: UIInterfaceOrientation) -> Bool {
        switch interfaceOrientation {
        case .portrait:
            return isSupportPortrait()
        case .landscapeLeft:
            return isSupportLandscapeLeft()
        case .landscapeRight:
            return isSupportLandscapeRight()
        case .portraitUpsideDown:
            return isSupportPortraitUpsideDown()
        default:
            return false
        }
    }
    
    func willChange(_ orientation: UIInterfaceOrientation) {
        isFullScreen = UIInterfaceOrientationIsLandscape(orientation)
        orientationWillChange?(isFullScreen)
    }
    
    func didChanged(_ orientation: UIInterfaceOrientation) {
        isFullScreen = UIInterfaceOrientationIsLandscape(orientation)
        orientationDidChanged?(isFullScreen)
    }
    
    func isSupportPortrait() -> Bool {
        supportInterfaceOrientation.contains(.portrait)
    }
    
    func isSupportPortraitUpsideDown() -> Bool {
        supportInterfaceOrientation.contains(.portaitUpsideDown)
    }
    
    func isSupportLandscapeLeft() -> Bool {
        supportInterfaceOrientation.contains(.landspaceLeft)
    }
    
    func isSupportLandscapeRight() -> Bool {
        supportInterfaceOrientation.contains(.landscapeRight)
    }
}

extension GKRotationManager {
    private static let onceToken = UUID().uuidString
    @objc static func gkAwake() {
        if #available(iOS 16.0, *) { return }
        if #available(iOS 13.0, *) {
            let cls = UIViewController.self
            /// _setContentOverlayInsets:andLeftMargin:rightMargin:
            let data = Data(base64Encoded: "X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOmFuZExlZnRNYXJnaW46cmlnaHRNYXJnaW46", options: .ignoreUnknownCharacters)
            
            guard let data = data else { return }
            let method = String(data: data, encoding: .utf8)
            guard let method = method else { return }
            let originalSelector = NSSelectorFromString(method)
            let swizzledSelector = NSSelectorFromString("gk" + method)
            
            let originalMethod = class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
            guard let originalMethod = originalMethod, let swizzledMethod = swizzledMethod else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension UIViewController {
    @objc func gk_setContentOverlayInsets(_ insets: UIEdgeInsets, andLeftMargin: CGFloat, rightMargin: CGFloat) {
        var keyWindow = UIApplication.shared.keyWindow
        if keyWindow == nil {
            if #available(iOS 13.0, *) {
                keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
            }
        }
        let otherWindow = view.window
        guard let keyWindow = keyWindow else { return }
        if let window = keyWindow as? GKLandscapeWindow, let otherWindow = otherWindow {
            let superviewWindow = window.rotationManager?.containerView?.window
            if superviewWindow != otherWindow {
                gk_setContentOverlayInsets(insets, andLeftMargin: andLeftMargin, rightMargin: rightMargin)
            }
        }else {
            gk_setContentOverlayInsets(insets, andLeftMargin: andLeftMargin, rightMargin: rightMargin)
        }
    }
}
