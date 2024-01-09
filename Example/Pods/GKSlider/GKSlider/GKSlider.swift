//
//  GKSlider.swift
//  GKSlider
//
//  Created by QuintGao on 2023/8/31.
//

import UIKit

public protocol GKSliderPreviewDelegate: NSObjectProtocol {
    /// 设置预览试图
    func setupPreview(for slider: GKSlider) -> UIView?
    /// 预览试图底部与滑杆中心的间距，默认 10
    func previewMargin(for slider: GKSlider) -> CGFloat
    /// 滑杆进度改变
    func valueChanged(for slider: GKSlider, preview: UIView?, value: Float)
}
public extension GKSliderPreviewDelegate {
    func previewMargin(for slider: GKSlider) -> CGFloat { 10 }
    func valueChanged(for slider: GKSlider, preview: UIView?, value: Float) {}
}

public protocol GKSliderDelegate: NSObjectProtocol {
    /// 滑块滑动开始
    func touchBegan(for slider: GKSlider, value: Float)
    /// 滑块滑动结束
    func touchEnded(for slider: GKSlider, value: Float)
    /// 滑块滑动中
    func valueChange(for slider: GKSlider, value: Float)
    /// 滑杆点击
    func tapped(for slider: GKSlider, value: Float)
}
public extension GKSliderDelegate {
    func touchBegan(for slider: GKSlider, value: Float) {}
    func touchEnded(for slider: GKSlider, value: Float) {}
    func valueChange(for slider: GKSlider, value: Float) {}
    func tapped(for slider: GKSlider, value: Float) {}
}

open class GKSliderButton: UIButton {
    public var enlargeEdge: UIEdgeInsets = .zero
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = false
        indicator.isUserInteractionEnabled = false
        indicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        indicator.transform = CGAffineTransformMakeScale(0.6, 0.6)
        indicator.isHidden = true
        return indicator
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(indicatorView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        indicatorView.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6)
    }
    
    public func showActivityAnim() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    public func hideActivityAnim() {
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = enlargedRect()
        if CGRectEqualToRect(rect, bounds) {
            return super.point(inside: point, with: event)
        }
        return CGRectContainsPoint(rect, point)
    }
    
    private func enlargedRect() -> CGRect {
        return CGRect(x: bounds.origin.x - enlargeEdge.left,
                      y: bounds.origin.y - enlargeEdge.top,
                      width: bounds.width + enlargeEdge.left + enlargeEdge.right,
                      height: bounds.height + enlargeEdge.top + enlargeEdge.bottom)
    }
}

open class GKLineLoadingView: UIView {
    public class func showLoading(in view: UIView, lineHeight: CGFloat) {
        let loadingView = GKLineLoadingView(frame: view.frame, lineHeight: lineHeight)
        view.addSubview(loadingView)
        loadingView.startLoading()
    }
    
    public class func hideLoading(in view: UIView) {
        view.subviews.reversed().forEach {
            if let loadingView = $0 as? GKLineLoadingView {
                loadingView.stopLoading()
                loadingView.removeFromSuperview()
            }
        }
    }
    
    public convenience init(frame: CGRect, lineHeight: CGFloat) {
        self.init(frame: frame)
        backgroundColor = .white
        center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        bounds = CGRect(x: 0, y: 0, width: 1.0, height: lineHeight)
    }
    
    public func startLoading() {
        stopLoading()
        isHidden = false
        
        // 创建动画组
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.75
        animationGroup.beginTime = CACurrentMediaTime()
        animationGroup.repeatCount = MAXFLOAT
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // x轴缩放动画(transform.scale是以view的中心点位中心开始缩放的)
        let scaleAnimation = CABasicAnimation()
        scaleAnimation.keyPath = "transform.scale.x"
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = superview?.frame.width
        
        // 透明度渐变动画
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0.5
        
        animationGroup.animations = [scaleAnimation, alphaAnimation]
        // 添加动画
        layer.add(animationGroup, forKey: "lineLoading")
    }
    
    public func stopLoading() {
        layer.removeAnimation(forKey: "lineLoading")
        isHidden = true
    }
}

private let kSliderBtnWH: CGFloat = 19
private let kProgressMargin: CGFloat = 2
private let kProgressH: CGFloat = 3

open class GKSlider: UIView {
    // 代理
    public weak var delegate: GKSliderDelegate?
    // 预览试图代理
    public weak var previewDelegate: GKSliderPreviewDelegate? {
        didSet {
            guard let superview = superview else { return }
            preview = previewDelegate?.setupPreview(for: self)
            guard let preview = preview else { return }
            preview.isHidden = true
            superview.addSubview(preview)
        }
    }
    
    // 默认滑杆颜色，默认灰色
    public var maximumTrackTintColor: UIColor = .gray {
        didSet {
            bgProgressView.backgroundColor = maximumTrackTintColor
        }
    }
    // 滑杆进度颜色，默认红色
    public var minimumTrackTintColor: UIColor = .red {
        didSet {
            sliderProgressView.backgroundColor = minimumTrackTintColor
        }
    }
    // 缓存进度颜色，默认白色
    public var bufferTrackTintColor: UIColor = .white {
        didSet {
            bufferProgressView.backgroundColor = bufferTrackTintColor
        }
    }
    
    // 默认滑杆图片
    public var maximumTrackImage: UIImage? {
        didSet {
            bgProgressView.image = maximumTrackImage
            maximumTrackTintColor = .clear
        }
    }
    // 滑杆进度图片
    public var minimumTrackImage: UIImage? {
        didSet {
            sliderProgressView.image = minimumTrackImage
            minimumTrackTintColor = .clear
        }
    }
    // 缓存进度图片
    public var bufferTrackImage: UIImage? {
        didSet {
            bufferProgressView.image = bufferTrackImage
            bufferTrackTintColor = .clear
        }
    }
    
    // 滑杆进度
    public var value: Float = 0 {
        didSet {
            let finishValue = (bgProgressView.frame.width - 2 * ignoreMargin) * CGFloat(value) + ignoreMargin
            var frame = sliderProgressView.frame
            frame.size.width = finishValue
            sliderProgressView.frame = frame
            
            frame = sliderBtn.frame
            frame.origin.x = (self.frame.width - 2 * ignoreMargin - sliderBtn.frame.width) * CGFloat(value) + ignoreMargin
            sliderBtn.frame = frame
            setupSliderRoundCorner()
        }
    }
    // 缓存进度
    public var bufferValue: Float = 0 {
        didSet {
            let finishValue = (bgProgressView.frame.width - 2 * ignoreMargin) * CGFloat(bufferValue) + ignoreMargin
            var frame = bufferProgressView.frame
            frame.size.width = finishValue
            bufferProgressView.frame = frame
            setupBufferRoundCorner()
        }
    }
    
    // MARK: 滑杆
    // 滑杆是否允许点击，默认YES
    public lazy var sliderBtn: GKSliderButton = {
        let btn = GKSliderButton()
        btn.addTarget(self, action: #selector(sliderBtnTouchBegan), for: .touchDown)
        btn.addTarget(self, action: #selector(sliderBtnTouchEnded), for: .touchCancel)
        btn.addTarget(self, action: #selector(sliderBtnTouchEnded), for: .touchUpInside)
        btn.addTarget(self, action: #selector(sliderBtnTouchEnded), for: .touchUpOutside)
        btn.addTarget(self, action: #selector(sliderBtnDragMoving), for: .touchDragInside)
        btn.addTarget(self, action: #selector(sliderBtnDragMoving), for: .touchDragOutside)
        return btn
    }()
    
    public var isSliderAllowTapped: Bool = true {
        didSet {
            if isSliderAllowTapped {
                addGestureRecognizer(tapGesture)
            }else {
                if gestureRecognizers?.contains(tapGesture) == true {
                    removeGestureRecognizer(tapGesture)
                }
            }
        }
    }
    
    // 滑杆是否允许拖拽，默认NO
    public var isSliderAllowDragged: Bool = false {
        didSet {
            if isSliderAllowTapped {
                sliderBtn.isUserInteractionEnabled = false
                addGestureRecognizer(panGesture)
            }else {
                if isSliderBlockAllowTapped {
                    sliderBtn.isUserInteractionEnabled = true
                }
                if gestureRecognizers?.contains(panGesture) == true {
                    removeGestureRecognizer(panGesture)
                }
            }
        }
    }
    
    // 滑杆高度，默认 3
    public var sliderHeight: CGFloat = 3 {
        didSet {
            bgProgressView.frame.size.height = sliderHeight
            bufferProgressView.frame.size.height = sliderHeight
            sliderProgressView.frame.size.height = sliderHeight
        }
    }
    
    // 滑杆圆角半径
    public var cornerRadius: CGFloat = 0 {
        didSet {
            bgProgressView.layer.cornerRadius = cornerRadius
            bgProgressView.layer.masksToBounds = true
            
            bufferProgressView.layer.cornerRadius = cornerRadius
            bufferProgressView.layer.masksToBounds = true
            
            sliderProgressView.layer.cornerRadius = cornerRadius
            sliderProgressView.layer.masksToBounds = true
        }
    }
    
    // 滑杆背景圆角半径，设置次属性滑杆进度和缓存进度不为1时只会左边切圆角，为1时右边切圆角
    public var bgCornerRadius: CGFloat = 0 {
        didSet {
            bgProgressView.layer.cornerRadius = bgCornerRadius
            bgProgressView.layer.masksToBounds = true
            setupBufferRoundCorner()
            setupSliderRoundCorner()
        }
    }
    
    // 忽略间距，设置此属性，滑杆左右会有相应的距离不计入滑杆的进度，默认0
    public var ignoreMargin: CGFloat = 0
    
    // MARK: 滑块
    // 滑块中心点的Y值，默认 0：表示 GKSlider 的中心
    public var sliderBlockCenterY: CGFloat = 0
    
    // 是否隐藏滑块，默认false
    public var isHideSliderBlock: Bool = false {
        didSet {
            sliderBtn.isHidden = isHideSliderBlock
        }
    }
    
    // 是否允许滑块点击，默认 YES
    public var isSliderBlockAllowTapped: Bool = true {
        didSet {
            if isSliderAllowDragged {
                sliderBtn.isUserInteractionEnabled = false
            }else {
                sliderBtn.isUserInteractionEnabled = isSliderBlockAllowTapped
            }
        }
    }
    
    // 滑块扩大的点击范围，默认10
    public var sliderBlockEnlargeEdge: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            sliderBtn.enlargeEdge = sliderBlockEnlargeEdge
        }
    }
    
    // 预览试图
    public var preview: UIView?
    
    // 预览试图位置是否跟随滑块改变，默认YES，为 NO时显示在中间
    public var isPreviewChangePosition: Bool = true
    
    // 加载动画的高度，默认滑杆高度
    public var lineHeight: CGFloat = 0
    
    // 是否正在拖拽
    public var isDragging: Bool = false
    
    private var touchPoint: CGPoint = .zero
    private var touchValue: Float = 0
    
    private lazy var bgProgressView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var bufferProgressView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var sliderProgressView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTap))
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let newSuperview = newSuperview else { return }
        preview = previewDelegate?.setupPreview(for: self)
        guard let preview = preview else { return }
        preview.isHidden = true
        newSuperview.addSubview(preview)
    }
    
    private func initUI() {
        isSliderAllowTapped = true
        isSliderBlockAllowTapped = true
        isPreviewChangePosition = true
        sliderBtn.enlargeEdge = sliderBlockEnlargeEdge
        backgroundColor = .clear
        
        addSubview(bgProgressView)
        addSubview(bufferProgressView)
        addSubview(sliderProgressView)
        addSubview(sliderBtn)
        
        bgProgressView.frame = CGRect(x: kProgressMargin, y: 0, width: 0, height: kProgressH)
        bufferProgressView.frame = bgProgressView.frame
        sliderProgressView.frame = bgProgressView.frame
        sliderBtn.frame = CGRect(x: 0, y: 0, width: kSliderBtnWH, height: kSliderBtnWH)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if sliderBtn.isHidden {
            bgProgressView.frame.size.width = self.frame.size.width
        }else {
            bgProgressView.frame.size.width = self.frame.size.width - kProgressMargin * 2
        }
        
        bgProgressView.center.y = frame.height * 0.5
        bufferProgressView.center.y = frame.height * 0.5
        sliderProgressView.center.y = frame.height * 0.5
        sliderBtn.center.y = frame.height * 0.5
        
        let value = self.value
        self.value = value
        let bufferValue = self.bufferValue
        self.bufferValue = bufferValue
        
        let margin = previewDelegate?.previewMargin(for: self) ?? 10
        var point = self.convert(sliderBtn.center, to: superview)
        if !isPreviewChangePosition {
            point.x = (superview?.frame.width ?? 0) * 0.5
        }
        
        guard let preview = preview else { return }
        preview.center.x = point.x
        preview.center.y = point.y - preview.frame.height - margin
    }
    
    public func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        sliderBtn.setBackgroundImage(image, for: state)
        sliderBtn.sizeToFit()
    }
    
    public func setThumbImage(_ image: UIImage?, for state: UIControl.State) {
        sliderBtn.setImage(image, for: state)
        sliderBtn.sizeToFit()
    }
    
    public func showLoading() {
        sliderBtn.showActivityAnim()
    }
    
    public func hideLoading() {
        sliderBtn.hideActivityAnim()
    }
    
    public func showLineLoading() {
        bgProgressView.isHidden = true
        bufferProgressView.isHidden = true
        sliderProgressView.isHidden = true
        sliderBtn.isHidden = true
        
        let lineHeight = self.lineHeight > 0 ? self.lineHeight : bgProgressView.frame.height
        GKLineLoadingView.showLoading(in: self, lineHeight: lineHeight)
    }
    
    public func hideLineLoading() {
        bgProgressView.isHidden = false
        bufferProgressView.isHidden = false
        sliderProgressView.isHidden = false
        sliderBtn.isHidden = false
        GKLineLoadingView.hideLoading(in: self)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        if CGRectContainsPoint(sliderBtn.frame, point) { return }
        
        // 获取进度
        let value = (point.x - ignoreMargin - bgProgressView.frame.origin.x) * 1.0 / (bgProgressView.frame.width - 2 * ignoreMargin)
        // value的值需在0-1之间
        let newValue = Float(min(max(0, value), 1))
        self.value = newValue
        delegate?.tapped(for: self, value: newValue)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        switch gesture.state {
        case .began:
            touchPoint = location
            touchValue = value
            sliderTouchBegan(sliderBtn)
        case .changed:
            // 差值
            guard let width = gesture.view?.frame.width else { return }
            let diff = (location.x - touchPoint.x) / width
            let value = touchValue + Float(diff)
            sliderTouchMoving(value)
        case .ended:
            sliderTouchEnded(sliderBtn)
        default:
            break
        }
    }
    
    @objc private func sliderBtnTouchBegan(_ btn: UIButton, event: UIEvent) {
        guard let touches = event.allTouches else { return }
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        touchPoint = touch.location(in: self)
        sliderTouchBegan(btn)
    }
    
    @objc private func sliderBtnTouchEnded(_ btn: UIButton) {
        sliderTouchEnded(btn)
    }
    
    @objc private func sliderBtnDragMoving(_ btn: UIButton, event: UIEvent) {
        // 点击的位置
        guard let touches = event.allTouches else { return }
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        let point = touch.location(in: self)
        // 修复真机测试时按下就触发移动方法导致的 bug
        if touchPoint == point { return }
        // 获取进度值 由于btn是从 0-(self.width - btn.width)
        let value = (point.x - ignoreMargin - btn.frame.width * 0.5) / (frame.width - 2 * ignoreMargin - btn.frame.width)
        sliderTouchMoving(Float(value))
    }
    
    private func sliderTouchBegan(_ btn: UIButton) {
        isDragging = true
        delegate?.touchBegan(for: self, value: value)
        if let preview = preview {
            preview.isHidden = false
        }
    }
    
    private func sliderTouchEnded(_ btn: UIButton) {
        isDragging = false
        delegate?.touchEnded(for: self, value: value)
        if let preview = preview {
            preview.isHidden = true
        }
    }
    
    private func sliderTouchMoving(_ value: Float) {
        // value的值需在0-1之间
        let newValue = min(max(0, value), 1)
        self.value = newValue
        delegate?.valueChange(for: self, value: newValue)
        previewDelegate?.valueChanged(for: self, preview: preview, value: newValue)
    }
    
    private func setupSliderRoundCorner() {
        let cornerRadius = bgCornerRadius
        if cornerRadius == 0 { return }
        let value = self.value
        
        let corner: UIRectCorner = value == 1 ? [.allCorners] : [.topLeft, .bottomLeft]
        let frame = bgProgressView.bounds
        
        let maskPath = UIBezierPath(roundedRect: frame, byRoundingCorners: corner, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = frame
        maskLayer.path = maskPath.cgPath
        sliderProgressView.layer.mask = maskLayer
    }
    
    private func setupBufferRoundCorner() {
        let cornerRadiuse = bgCornerRadius
        if cornerRadiuse == 0 { return }
        
        let value = self.value
        let corner: UIRectCorner = value == 1 ? [.allCorners] : [.topLeft, .bottomLeft]
        let frame = bgProgressView.bounds
        
        let maskPath = UIBezierPath(roundedRect: frame, byRoundingCorners: corner, cornerRadii: CGSize(width: cornerRadiuse, height: cornerRadiuse))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = frame
        maskLayer.path = maskPath.cgPath
        bufferProgressView.layer.mask = maskLayer
    }
}
