//
//  HeroBrowser.swift
//  Example
//
//  Created by 逸风 on 2021/8/7.
//

import UIKit

class PageControlContainer: UIView {
    
    private var pageControl: UIPageControl?
    private var pageLabel: UILabel?
    typealias DidChangePageHandle = (UIPageControl) -> ()
    var didChangePageHandle: DidChangePageHandle?
    
    var currentPage: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.pageControl?.currentPage = self.currentPage
                self.pageLabel?.text = "\(self.currentPage)/\(self.numberOfPages)"
            }
        }
    }
    
    var numberOfPages: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pageControl?.frame = self.bounds
        self.pageLabel?.frame = self.bounds
    }
    
    func updateView(with type: JFHeroBrowserPageControlType, numberOfPages: Int) {
        self.numberOfPages = numberOfPages
        var type = type
        var available = false
        if #available(iOS 14.0, *) {
            available = true
        }
        if !available && numberOfPages > 9 {
            type = .number
        }
        if type == .pageControl  {
            let pageC = UIPageControl()
            pageC.addTarget(self, action: #selector(changePage(pageControl:)), for: .valueChanged)
            pageC.hidesForSinglePage = true
            pageC.numberOfPages = numberOfPages
            self.pageControl = pageC
            self.addSubview(pageC)
        } else if type == .number {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .white
            self.pageLabel = label
            self.addSubview(label)
        } else {
            self.isHidden = true
        }
    }
    
    @objc func changePage(pageControl: UIPageControl) {
        self.didChangePageHandle?(pageControl)
    }
}

@objc public protocol HeroBrowserDataSource: AnyObject {
    @objc func viewForHeader() -> UIView?
    @objc func viewForFooter() -> UIView?
}

public protocol HeroBrowserDelegate: AnyObject {
    func heroBrowser(_ heroBrowser: HeroBrowser, didLongPressHandle viewModule: HeroBrowserViewModuleBaseProtocol)
}

extension HeroBrowserDelegate {
    func heroBrowser(_ heroBrowser: HeroBrowser, didLongPressHandle viewModule: HeroBrowserViewModuleBaseProtocol) {}
}

open class HeroBrowser: UIViewController {
    
    public typealias HeroBrowserDidLongPressHandle = (_ heroBrowser: HeroBrowser, _ viewModule: HeroBrowserViewModuleBaseProtocol) -> ()
    public var heroBrowserDidLongPressHandle: HeroBrowserDidLongPressHandle?
    
    lazy var effect = { UIBlurEffect(style: .dark) }()
    var blurEffectView: UIVisualEffectView?
    
    var config: JFHeroBrowserGlobalConfig = .default
    
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
        view.showsHorizontalScrollIndicator = false
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
    public weak var delegate: HeroBrowserDelegate?
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
    public private(set) var _viewModules: [HeroBrowserViewModuleBaseProtocol]?
    private var _index: Int = 0
    var isShow = false
    var _scrolling: Bool = false
    var currentIndex: Int {
        get {
            let index = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
            let count = _viewModules?.count ?? 0
            return index < count ? index : count
        }
    }
    
    public typealias ImagePageDidChangeHandle = (_ imageIndex: Int) -> UIImageView?
    public var imagePageDidChangeHandle: ImagePageDidChangeHandle?
    var heroImageView: UIImageView?
    var heroFrame: CGRect = .zero
    var heroImage: UIImage?
    var heroContentMode: UIView.ContentMode = .scaleAspectFill
    
    private lazy var pageControlContainer: PageControlContainer = {
        var view = PageControlContainer()
        view.didChangePageHandle = { [weak self] pageControl in
            self?.changePage(pageControl: pageControl)
        }
        self.view.addSubview(view)
        view.backgroundColor = .clear
        view.jf.height = 20
        view.jf.width = 250
        view.jf.centerX = self.view.jf.centerX
        view.jf.bottom = CGSize.jf.screenHeight() - CGFloat.jf.safeAreaBottomHeight() - 15
        return view
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    deinit {
        print("HeroBrowser deinit")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(noti:)), name:UIDevice.orientationDidChangeNotification, object: UIDevice.current)
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
            self.footerView?.jf.bottom = CGSize.jf.screenHeight()
        }
        
        let pageCount = _viewModules?.count ?? 0
        self.pageControlContainer.updateView(with: self.config.pageControlType, numberOfPages: pageCount)
        if self.config.enableBlurEffect {
            enableBlurEffet()
        }
    }
    
    public convenience init(viewModules: [HeroBrowserViewModuleBaseProtocol], index: Int, heroImageView: UIImageView? = nil, imagePageDidChangeHandle: ImagePageDidChangeHandle? = nil, config: JFHeroBrowserGlobalConfig = .default) {
        self.init()
        self.config = config
        self.heroImageView = heroImageView
        self.imagePageDidChangeHandle = imagePageDidChangeHandle
        _viewModules = viewModules
        _index = index
        self.transitionContext = self
        self.setupView()
        self.setupGestureRecognizer()
        self.switchToPage(index: index)
        self.updatepageControlContainer(index: index)
        self.indexChangeHandle(index: index)
        self.prefetchImages()
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
    
    //preset to override
    open func indexChangeHandle(index: Int) {
        
    }
    
    func updatepageControlContainer(index: Int) {
        guard index < self.pageControlContainer.numberOfPages  else { return }
        self.pageControlContainer.currentPage = index
    }
    
    func updateHeroView(index: Int) {
        guard index < _viewModules?.count ?? 0  else { return }
        self.heroImageView = self.imagePageDidChangeHandle?(index)
    }
    
    @objc func changePage(pageControl: UIPageControl) {
        self.updateHeroView(index: pageControl.currentPage)
        self.switchToPage(index: pageControl.currentPage)
    }
    
    // 预加载左右各一张
    func prefetchImages() {
        guard let vms = _viewModules else { return }
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
    
    func enableBlurEffet() {
        self.blurView.backgroundColor = .clear
        let blurEffectView = UIVisualEffectView(effect: self.effect)
        blurEffectView.frame = self.view.bounds
        self.blurView.addSubview(blurEffectView)
        self.blurEffectView = blurEffectView
    }

}

extension HeroBrowser: UIGestureRecognizerDelegate {
    func setupGestureRecognizer() {
        let singleFingerOne = UITapGestureRecognizer(target: self, action: #selector(handleSingleFingerEvent(gesture:)))
        singleFingerOne.numberOfTouchesRequired = 1;
        singleFingerOne.numberOfTapsRequired = 1
        singleFingerOne.delegate = self
        self.view.addGestureRecognizer(singleFingerOne)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressEvent(gesture:)))
        self.view.addGestureRecognizer(longPress)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleFingerEvent(gesture:)))
        doubleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.delegate = self
        self.view.addGestureRecognizer(doubleTap)
        singleFingerOne.require(toFail: doubleTap)
    }
    
    @objc func handleLongPressEvent(gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let vm = _viewModules?[self.currentIndex] else { return }
        if let del = self.delegate {
            del.heroBrowser(self, didLongPressHandle: vm)
            return
        }
        self.heroBrowserDidLongPressHandle?(self, vm)
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

extension HeroBrowser: UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize.jf.screenSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _viewModules?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt index \(indexPath.item)")
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
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplay cell index \(indexPath.item)")
        guard let vm = _viewModules?[indexPath.item] else {
            return
        }
        guard let cell = cell as? HeroBrowserBaseImageCell else { return }
        if let vm = vm as? HeroBrowserViewModule {
            cell.viewModule = vm
        } else if let vm = vm as? HeroBrowserVideoViewModule {
            cell.videoViewModule = vm
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? HeroBrowserVideoCell {
            videoCell.videoView.pauseVideo()
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _scrolling = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX: CGFloat = scrollView.contentOffset.x
        let currentIndex: Int = Int((contentOffsetX + 0.5 * self.view.frame.size.width) / self.view.frame.size.width)
        self.updateHeroView(index: currentIndex)
        self.updatepageControlContainer(index: currentIndex)
        self.indexChangeHandle(index: currentIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _scrolling = false
        self.prefetchImages()
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

extension HeroBrowser {
    
    func updateFooterOrHeaderView() {
        if var footer = self.footerView {
            let size = footer.jf.size
            footer.jf.width = CGSize.jf.screenWidth()
            footer.jf.height = size.height
            footer.jf.bottom = CGSize.jf.screenHeight()
        }
        if var header = self.headerView {
            let size = header.jf.size
            header.jf.width = CGSize.jf.screenWidth()
            header.jf.height = size.height
        }
    }
    
    @objc func orientationChanged(noti: Notification) {
        DispatchQueue.main.async {
            let bounds = UIScreen.main.bounds
            let screenSize = UIScreen.main.bounds.size
            //竖屏
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                let index = self.pageControlContainer.currentPage
                self.blurView.frame = bounds
                self.blurEffectView?.frame = bounds
                self.collectionView.frame = CGSize.jf.screenBounds()
                self.pageControlContainer.jf.centerX = self.collectionView.jf.centerX
                self.pageControlContainer.jf.bottom = CGSize.jf.screenHeight() - CGFloat.jf.safeAreaBottomHeight() - 15
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                self.updateFooterOrHeaderView()
            } else {
                if screenSize.width < screenSize.height {
                    let index = self.pageControlContainer.currentPage
                    self.blurView.frame = bounds
                    self.blurEffectView?.frame = bounds
                    self.collectionView.frame = CGSize.jf.screenBounds()
                    self.pageControlContainer.jf.centerX = self.collectionView.jf.centerX
                    self.pageControlContainer.jf.bottom = CGSize.jf.screenHeight() - CGFloat.jf.safeAreaBottomHeight() - 15
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                    self.updateFooterOrHeaderView()
                }
            }
        }
    }
}
