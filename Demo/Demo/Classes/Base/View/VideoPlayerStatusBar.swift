//
//  VideoPlayerStatusBar.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import Alamofire

class VideoPlayerStatusBar: UIView {
    // 刷新时间间隔，默认3秒
    public var refreshTime: TimeInterval = 3
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.bounds = CGRectMake(0, 0, 100, 16)
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var batteryView: UIView = {
        return UIView()
    }()
    
    private lazy var batteryImageView: UIView = {
        let imgView = UIImageView()
        imgView.bounds = CGRectMake(0, 0, 8, 12)
        imgView.center = CGPointMake(10, 5)
        imgView.image = UIImage(named: "icon_battery_lightning")
        return imgView
    }()
    
    private lazy var batteryLayer: CAShapeLayer = {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryPath = UIBezierPath(roundedRect: CGRectMake(1.5, 1.5, (20-3)*CGFloat(batteryLevel), 10-3), cornerRadius: 2)
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.strokeColor = UIColor.clear.cgColor
        layer.path = batteryPath.cgPath
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()
    
    private lazy var batteryBoundLayer: CAShapeLayer = {
        let bezierPath = UIBezierPath(roundedRect: CGRectMake(0, 0, 20, 10), cornerRadius: 2.5)
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.path = bezierPath.cgPath
        layer.fillColor = nil
        return layer
    }()
    
    private lazy var batteryPositiveLayer: CAShapeLayer = {
        let path = UIBezierPath(roundedRect: CGRectMake(22, 3, 1, 3), byRoundingCorners: [.topLeft, .bottomRight], cornerRadii: CGSizeMake(2, 2))
        let layer = CAShapeLayer()
        layer.lineWidth = 0.5
        layer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor
        return layer
    }()
    
    private lazy var batteryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var networkLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 7
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.textColor = .white
        label.font = .systemFont(ofSize: 9)
        label.textAlignment = .center
        label.text = "WIFI"
        return label
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var timer: Timer?
    
    public var network: String? {
        didSet {
            networkLabel.text = network
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.sizeToFit()
        networkLabel.sizeToFit()
        batteryLabel.sizeToFit()
        
        dateLabel.frame.size = CGSizeMake(dateLabel.frame.width, 16)
        batteryView.frame = CGRectMake(bounds.width - 35, 0, 22, 10)
        batteryLabel.frame = CGRectMake(batteryView.frame.origin.x - 42, 0, batteryLabel.frame.width, 16)
        networkLabel.frame = CGRectMake(batteryLabel.frame.origin.x - 40, 0, networkLabel.frame.width + 13, 14)
        
        dateLabel.center = center
        batteryView.center.y = center.y
        batteryLabel.frame.origin.x = batteryView.frame.origin.x - 5 - batteryLabel.frame.width
        batteryLabel.center.y = center.y
        networkLabel.frame.origin.x = 10
        networkLabel.center.y = center.y
    }
    
    deinit {
        destoryTimer()
        removeNotifications()
    }
    
    private func setup() {
        refreshTime = 3
        /// 时间
        addSubview(dateLabel)
        /// 电池
        addSubview(batteryView)
        batteryView.layer.addSublayer(batteryBoundLayer)
        /// 正极
        batteryView.layer.addSublayer(batteryPositiveLayer)
        /// 是否在充电
        batteryView.layer.addSublayer(batteryLayer)
        batteryView.addSubview(batteryImageView)
        addSubview(batteryLabel)
        addSubview(networkLabel)
        
        addNotifications()
    }
    
    private func addNotifications() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localeDidChange), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkDidChange), name: NetworkChange, object: nil)
    }
    
    private func removeNotifications() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NetworkChange, object: nil)
    }
    
    @objc private func batteryLevelDidChange(_ notify: Notification) {
        updateUI()
    }
    
    @objc private func batteryStateDidChange(_ notify: Notification) {
        updateUI()
    }
    
    @objc private func localeDidChange(_ notify: Notification) {
        dateFormatter.locale = .current
        updateUI()
    }
    
    @objc private func networkDidChange(_ notify: Notification) {
        guard let userInfo = notify.userInfo else { return }
        guard let status = userInfo["network"] as? String else { return }
        networkLabel.text = network
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    @objc private func updateUI() {
        updateDate()
        updateBattery()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateDate() {
        let dateString = NSMutableString(string: dateFormatter.string(from: Date()))
        let amRange = dateString.range(of: dateFormatter.amSymbol)
        let pmRange = dateString.range(of: dateFormatter.pmSymbol)
        if amRange.location != NSNotFound {
            dateString.deleteCharacters(in: amRange)
        }else if pmRange.location != NSNotFound {
            dateString.deleteCharacters(in: pmRange)
        }
        dateLabel.text = dateString as String
    }
    
    private func updateBattery() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        var batteryLevel: CGFloat = CGFloat(UIDevice.current.batteryLevel)
        /// -1是模拟器
        if batteryLevel < 0 { batteryLevel = 1.0 }
        let rect = CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3)
        let batteryPath = UIBezierPath(roundedRect: rect, cornerRadius: 2)
        
        var batterColor: UIColor? = nil
        let batteryState = UIDevice.current.batteryState
        if batteryState == .charging || batteryState == .full { /// 在充电
            batteryImageView.isHidden = false
        }else {
            batteryImageView.isHidden = true
        }
        if ProcessInfo.processInfo.isLowPowerModeEnabled { /// 低电量模式
            batterColor = UIColor(hex: 0xf9cf0e)
        }else {
            if batteryState == .charging || batteryState == .full { // 在充电
                batterColor = UIColor(hex: 0x37cb46)
            }else if batteryLevel <= 0.2 { // 电量低
                batterColor = UIColor(hex: 0xf20c2d)
            }else { // 电量正常，白色
                batterColor = .white
            }
        }
        batteryLayer.strokeColor = UIColor.clear.cgColor
        batteryLayer.path = batteryPath.cgPath
        batteryLayer.fillColor = batterColor?.cgColor
        batteryLabel.text = String(format: "%.0f%%", batteryLevel*100)
    }
    
    public func startTimer() {
        destoryTimer()
        timer = Timer(timeInterval: refreshTime, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        timer?.fire()
    }
    
    public func destoryTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
