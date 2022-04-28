//
//  HeroBrowser.swift
//  Example
//
//  Created by 逸风 on 2021/8/7.
//

import UIKit

@objc public protocol HeroBrowserDataSource: AnyObject {
    @objc func viewForHeader() -> UIView?
    @objc func viewForFooter() -> UIView?
}

public class HeroBrowser: UIViewController {
    
    lazy var blurView: UIView = {
        let view = UIView.init()
        view.frame = self.view.bounds
        view.backgroundColor = .black
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize.jf.screenSize()
        layout.scrollDirection = .horizontal
        let view = UICollectionView.init(frame: CGSize.jf.screenBounds(), collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.register(HeroBrowserNetworkImageCell.self, forCellWithReuseIdentifier: HeroBrowserNetworkImageCell.identify())
        view.register(HeroBrowserVideoCell.self, forCellWithReuseIdentifier: HeroBrowserVideoCell.identify())
        view.register(HeroBrowserBaseImageCell.self, forCellWithReuseIdentifier: HeroBrowserBaseImageCell.identify())
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    
    var animationType: HeroTransitionAnimationType = .hero
    public weak var dataSource: HeroBrowserDataSource?
    public weak var headerView: UIView?
    public weak var footerView: UIView?
    private var _isHideOther: Bool = false
    var isHideOther: Bool {
        set {
            guard _isHideOther != newValue else { return }
            _isHideOther = newValue
            let alpha: CGFloat = newValue ? 0 : 1
            UIView.animate(withDuration: 0.25) {
                self.headerView?.alpha = alpha
                self.footerView?.alpha = alpha
            }
        }
        get { _isHideOther }
    }
    weak var transitionContext: UIViewControllerAnimatedTransitioning?
    private var _viewModules: [HeroBrowserViewModuleBaseProtocol]?
    private var _index: Int = 0
    var isShow = false
    var _scrolling: Bool = false
    var currentIndex: Int {
        get {
            return Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        }
    }
    
    public typealias ImagePageDidChangeHandle = (_ imageIndex: Int) -> UIImageView?
    public var imagePageDidChangeHandle: ImagePageDidChangeHandle?
    var heroImageView: UIImageView?
    var heroFrame: CGRect = .zero
    var heroImage: UIImage?
    var heroContentMode: UIView.ContentMode = .scaleAspectFill
    
    private lazy var pageControl: UIPageControl = {
        var pageC = UIPageControl()
        self.view.addSubview(pageC)
        pageC.addTarget(self, action: #selector(changePage(pageControl:)), for: .valueChanged)
        pageC.hidesForSinglePage = true
        pageC.jf.height = 8
        pageC.jf.width = 250
        pageC.jf.left = (CGSize.jf.screenWidth() - 250) / 2
        pageC.jf.bottom = CGSize.jf.screenHeight() - CGFloat.jf.safeAreaBottomHeight() - 15
        return pageC
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    deinit {
        print("HeroBrowser deinit")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupView() {
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.collectionView)
        self.view.backgroundColor = .clear
        if let v = self.dataSource?.viewForHeader() {
            self.view.addSubview(v)
            self.headerView = v
        }
        if let v = self.dataSource?.viewForFooter() {
            self.view.addSubview(v)
            self.footerView = v
        }
        if let vm = _viewModules {
            self.pageControl.numberOfPages = vm.count
        }
    }
    
    public convenience init(viewModules: [HeroBrowserViewModuleBaseProtocol], index: Int, heroImageView: UIImageView? = nil, imagePageDidChangeHandle: ImagePageDidChangeHandle? = nil) {
        self.init()
        self.heroImageView = heroImageView
        self.imagePageDidChangeHandle = imagePageDidChangeHandle
        _viewModules = viewModules
        _index = index
        self.transitionContext = self
        self.setupView()
        self.setupGestureRecognizer()
        self.switchToPage(index: index)
        self.updatePageControl(index: index)
        self.prefetchImages(withoutCurrent: false)
    }
    
    public func show(with vc: UIViewController, animationType: HeroTransitionAnimationType = .hero) {
        self.animationType = animationType
        self.isShow = true
        let navi = UINavigationController.init(rootViewController: self)
        navi.transitioningDelegate = self
        navi.modalPresentationStyle = .custom
        vc.present(navi, animated: true, completion: nil)
    }
    
    public func hide(with completion: (() -> Void)?) {
        self.isShow = false
        self.dismiss(animated: true, completion: completion)
    }
    
    func switchToPage(index: Int) {
        self.collectionView.setContentOffset(CGPoint(x: Int(CGSize.jf.screenSize().width * CGFloat(index)), y: 0), animated: false)
    }
    
    func updatePageControl(index: Int) {
        guard index < self.pageControl.numberOfPages  else { return }
        self.pageControl.currentPage = index
    }
    
    func updateHeroView(index: Int) {
        guard index < _viewModules?.count ?? 0  else { return }
        if let heroV = self.imagePageDidChangeHandle?(index) {
            self.heroImageView = heroV
        }
    }
    
    @objc func changePage(pageControl: UIPageControl) {
        self.updateHeroView(index: pageControl.currentPage)
        self.switchToPage(index: pageControl.currentPage)
    }
    
    // 预加载左右各一张
    func prefetchImages(withoutCurrent isWithoutCurrent: Bool) {
        guard let vms = _viewModules else { return }
        let currentIndex = self.currentIndex
        if isWithoutCurrent == false {
            self.loadImage(index: currentIndex)
        }
        if (currentIndex > 0) {
            self.loadImage(index: currentIndex - 1)
        }
        if (currentIndex < vms.count) {
            self.loadImage(index: currentIndex + 1)
        }
    }
    
    func loadImage(index: Int) {
        guard let vms = _viewModules, index < vms.count, let networkVM = vms[index] as? HeroBrowserNetworkImageViewModule else { return }
        networkVM.asyncLoadRawSource(with: nil)
        networkVM.asyncLoadThumbailSource(with: nil)
    }

}

extension HeroBrowser: UIGestureRecognizerDelegate {
    func setupGestureRecognizer() {
        let singleFingerOne = UITapGestureRecognizer(target: self, action: #selector(handleSingleFingerEvent(gesture:)))
        singleFingerOne.numberOfTouchesRequired = 1;
        singleFingerOne.numberOfTapsRequired = 1;
        singleFingerOne.delegate = self
        self.view.addGestureRecognizer(singleFingerOne)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleFingerEvent(gesture:)))
        doubleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.delegate = self
        self.view.addGestureRecognizer(doubleTap)
        singleFingerOne.require(toFail: doubleTap)
    }
    
    @objc func handleSingleFingerEvent(gesture: UIGestureRecognizer) {
        if let cell = self.collectionView.cellForItem(at: self.currentIndexPath()) as? HeroBrowserCollectionCellProtocol {
            cell.resetZoom()
        }
        self.hide(with: nil)
    }

    @objc func handleDoubleFingerEvent(gesture: UIGestureRecognizer) {
        let touchLocation: CGPoint = gesture.location(in: gesture.view)
        if let cell = self.collectionView.cellForItem(at: self.currentIndexPath()) as? HeroBrowserCollectionCellProtocol {
            cell.doubleTap(location: touchLocation)
        }
    }
    
    //如果上层UI 有Button 拦截掉，不然会阻止Button Event
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: UIButton.self) ?? false {
            return false
        } else {
            return true
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func currentIndexPath() -> IndexPath {
        return IndexPath(item: self.currentIndex, section: 0)
    }
}

extension HeroBrowser: UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _viewModules?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let vm = _viewModules?[indexPath.item] else {
            return UICollectionViewCell()
        }
        let cell = vm.createCell(collectionView, indexPath)
        cell.getContainer().contentMode = self.heroContentMode
        cell.closeBlock = { [weak self] in
            guard let self = self else { return }
            self.animationType = .hero
            self.hide(with: nil)
        }
        cell.updatedContainerScaleBlock = { [weak self] scale in
            guard let self = self else { return }
            self.blurView.alpha = scale
            self.isHideOther = scale < 1
        }
        if let vm = vm as? HeroBrowserViewModule {
            cell.viewModule = vm
        } else if let vm = vm as? HeroBrowserVideoViewModule {
            cell.videoViewModule = vm
        }
        return cell
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _scrolling = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX: CGFloat = scrollView.contentOffset.x
        let currentIndex: Int = Int((contentOffsetX + 0.5 * self.view.frame.size.width) / self.view.frame.size.width)
        self.updateHeroView(index: currentIndex)
        self.updatePageControl(index: currentIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _scrolling = false
        self.prefetchImages(withoutCurrent: true)
    }
}

extension HeroBrowser:UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning {
    // 自定义 放大 缩小 转场
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionContext
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionContext
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isShow == true {
            self.present(transitonContext: transitionContext)
        } else {
            self.dismiss(transitonContext: transitionContext)
        }
    }
    
    func present(transitonContext: UIViewControllerContextTransitioning) {
        HeroTransitionAnimation.present(transitonContext: transitonContext, animationType: animationType, heroBrowser: self)
    }
    
    func dismiss(transitonContext: UIViewControllerContextTransitioning) {
        HeroTransitionAnimation.dismiss(transitonContext: transitonContext, animationType: animationType, heroBrowser: self)
    }
}
