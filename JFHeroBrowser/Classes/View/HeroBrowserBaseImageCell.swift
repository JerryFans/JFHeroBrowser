//
//  HeroBrowserBaseImageCell.swift
//  Example
//
//  Created by 逸风 on 2021/8/8.
//

import UIKit

open class HeroBrowserBaseImageCell: UICollectionViewCell {
    
    public var closeBlock: CloseBlock?
    public var updatedContainerScaleBlock: UpdatedContainerScaleBlock?
    public var beginTouchPoint: CGPoint = .zero
    public var beginFrame: CGRect = .zero
    
    var container: UIImageView = {
        let v = UIImageView()
        v.isUserInteractionEnabled = true
        v.clipsToBounds = true
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let tempView = UIScrollView.init(frame: UIScreen.main.bounds)
        tempView.showsHorizontalScrollIndicator = false
        tempView.showsVerticalScrollIndicator = false
        tempView.alwaysBounceVertical = false
        tempView.alwaysBounceHorizontal = true
        tempView.scrollsToTop = false
        tempView.backgroundColor = .clear
        tempView.maximumZoomScale = 3.0
        tempView.minimumZoomScale = 1.0
        tempView.setZoomScale(1, animated: false)
        if #available(iOS 11.0, *) {
            tempView.contentInsetAdjustmentBehavior = .never
        }
        tempView.delegate = self
        return tempView
    }()
    
    public var videoViewModule: HeroBrowserVideoViewModule? {
        didSet {
            self.beginLoadSource()
        }
    }
    
    public var viewModule: HeroBrowserViewModule? {
        didSet {
            self.beginLoadSource()
        }
    }
        
    func beginLoadSource() {
        guard let vm = viewModule else { return }
        vm.asyncLoadThumbailSource { result in
            switch result {
            case let .success(image):
                self.updateView(image: image)
                break
            case _ :
                break
            }
        }
        vm.asyncLoadRawSource { result in
            switch result {
            case let .success(image):
                self.updateView(image: image)
                break
            case _ :
                break
            }
        }
    }
    
    func updateView(image: UIImage) {
        self.container.image = image
        self.updateContainerFrame(with: image)
    }
    
    func updateContainerFrame(with image: UIImage) {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        if screenWidth < screenHeight {
            let height = image.size.height * screenWidth / image.size.width
            self.container.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: height)
            self.scrollView.contentSize = CGSize.init(width: self.container.frame.size.width, height: self.container.frame.size.height)
        } else {
            let width = image.size.width * screenHeight / image.size.height
            self.container.frame = CGRect.init(x: 0, y: 0, width: width, height: screenHeight)
            self.scrollView.contentSize = CGSize.init(width: self.container.frame.size.width, height: self.container.frame.size.height)
        }
        
        if screenWidth < screenHeight {
            if self.container.frame.size.height < self.scrollView.frame.size.height {
                var center = self.container.center
                center.y = self.scrollView.frame.size.height / 2
                self.container.center = center
            }
        } else {
            if self.container.frame.size.width < self.scrollView.frame.size.width {
                var center = self.container.center
                center.x = self.scrollView.frame.size.width / 2
                self.container.center = center
            }
        }
    }
    
    public static func identify() -> String {
        return NSStringFromClass(Self.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(noti:)), name:UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    func setupView() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.container)
        self.container.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        let panGest: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(onPan(gest:)))
        panGest.delegate = self
        self.scrollView.addGestureRecognizer(panGest)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginDragHandle() {
        
    }
    
    func endDragHandle() {
        
    }
    
}

extension HeroBrowserBaseImageCell: UIScrollViewDelegate {
    @objc private func onPan(gest: UIPanGestureRecognizer) {
        switch gest.state {
        case .began:
            self.beginFrame = self.container.frame
            self.beginTouchPoint = gest.location(in: self.scrollView)
            self.beginDragHandle()
            break
        case .changed:
            self.container.frame = self.getRectForPan(pan: gest)
            self.updatedContainerScaleBlock?(self.getScaleForPan(pan: gest))
            break
        case .ended,.cancelled:
            self.container.frame = self.getRectForPan(pan: gest)
            let isDown: Bool = gest.velocity(in: self).y > 0 ? true : false
            if isDown == true {
                self.resetZoom()
                self.closeBlock?()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.container.frame = self.beginFrame
                }
                self.updatedContainerScaleBlock?(1.0)
                self.endDragHandle()
            }
            break

        default:
            break
        }
    }

    private func getRectForPan(pan: UIPanGestureRecognizer) -> CGRect {
        var rect: CGRect = .zero
        guard self.beginFrame != CGRect.zero else {
            return rect
        }
        let currentTouch = pan.location(in: self.scrollView)
        let scale = self.getScaleForPan(pan: pan)
        let width = self.beginFrame.size.width * scale
        let  height = self.beginFrame.size.height * scale
        let xRate = (self.beginTouchPoint.x - self.beginFrame.origin.x) / self.beginFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX;
        let yRate = (self.beginTouchPoint.y - self.beginFrame.origin.y) / self.beginFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        rect = CGRect(x: x, y: y, width: width, height: height)
        return rect
    }

    private func getScaleForPan(pan: UIPanGestureRecognizer) -> CGFloat {
        let translation = pan.translation(in: self.scrollView)
        let scale: CGFloat = min(1.0, max(0.3, 1 - translation.y / self.bounds.size.height))
        return scale;
    }

    private func zoomRectForScale(scale: CGFloat,center: CGPoint) -> CGRect {
        var zoomRect: CGRect = .zero
        zoomRect.size.height = self.frame.size.height / scale
        zoomRect.size.width  = self.frame.size.width  / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect;
    }
}

extension HeroBrowserBaseImageCell: HeroBrowserCollectionCellProtocol {
    
    public func getContainer() -> UIView {
        return self.container
    }
    
    public func resetZoom()  {
        self.scrollView.setZoomScale(1.0, animated: true)
    }
    
    public func doubleTap(location: CGPoint) {
        if self.scrollView.zoomScale <= 1.0 {
            let gesturePointInImageView = self.container.convert(location, to: self)
            self.scrollView.zoom(to: self.zoomRectForScale(scale: 2.0, center: gesturePointInImageView), animated: true)
        } else {
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
}

extension HeroBrowserBaseImageCell {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.container
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var frame = self.container.frame;
        if self.container.frame.size.height < scrollView.frame.size.height {
            frame.origin.y = (self.scrollView.frame.size.height - self.container.frame.size.height) / 2
        } else {
            frame.origin.y = 0
        }
        self.container.frame = frame;
        if CGSize.jf.screenWidth() > CGSize.jf.screenHeight() {
            self.container.jf.centerX = scrollView.jf.centerX
        }
    }
}

extension HeroBrowserBaseImageCell:UIGestureRecognizerDelegate {
    
    @objc func orientationChanged(noti: Notification) {
        DispatchQueue.main.async {
            let screenSize = UIScreen.main.bounds.size
            //竖屏
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                self.scrollView.frame = UIScreen.main.bounds
            } else {
                if screenSize.width < screenSize.height {
                    self.scrollView.frame = UIScreen.main.bounds
                }
            }
        }
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            if self.scrollView.contentOffset.y > 0 {
                return false
            }
            let velocity: CGPoint = pan.velocity(in: self)
            if velocity.y < 0 {
                return false
            }
            if abs(Int(velocity.x)) > Int(velocity.y) {
                return false
            }
            return true
        } else {
            return true
        }
    }
}
