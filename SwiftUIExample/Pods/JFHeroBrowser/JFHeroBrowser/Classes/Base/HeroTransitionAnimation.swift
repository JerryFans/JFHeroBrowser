//
//  HeroTransitionAnimation.swift
//  HeroBrowser
//
//  Created by 逸风 on 2021/10/28.
//

import Foundation

public enum HeroTransitionAnimationType {
    case hero
}

public class HeroTransitionAnimation: NSObject {
    
    static func present(transitonContext: UIViewControllerContextTransitioning, animationType: HeroTransitionAnimationType, heroBrowser: HeroBrowser) {
        guard let fromVC = transitonContext.viewController(forKey:.from),
              let toVC = transitonContext.viewController(forKey:.to) else
              {
                  transitonContext.completeTransition(true)
                  return
              }
        
        let containerView = transitonContext.containerView
        containerView.addSubview(toVC.view)
        
        var cornerRadius: CGFloat = 0
        guard confirmOriginImageViewInfo(convertTo: fromVC.view, &cornerRadius, heroBrowser: heroBrowser), let originImage = heroBrowser.heroImage else {
            toVC.view.alpha = 0
            UIView.animate(withDuration: 0.2) {
                toVC.view.alpha = 1
            } completion: { _ in
                transitonContext.completeTransition(true)
            }
            return
        }
        
        let screenSize = CGSize.jf.screenSize()
        var moveFrame: CGRect = .zero
        
        if screenSize.width < screenSize.height {
            let moveW = CGSize.jf.screenWidth()
            let moveH = originImage.size.height * CGSize.jf.screenWidth() / originImage.size.width
            var moveY: CGFloat = 0.0
            if moveH < CGSize.jf.screenSize().height {
                moveY = HalfDiffValue(CGSize.jf.screenHeight(), moveH)
            }
            moveFrame = CGRect(x: 0.0, y: moveY, width: moveW, height: moveH)
        } else {
            let moveH = CGSize.jf.screenHeight()
            let moveW = originImage.size.width * moveH / originImage.size.height
            var moveX: CGFloat = 0.0
            if moveW < CGSize.jf.screenSize().width {
                moveX = HalfDiffValue(CGSize.jf.screenWidth(), moveW)
            }
            moveFrame = CGRect(x: moveX, y: 0, width: moveW, height: moveH)
        }
        heroBrowser.collectionView.isHidden = true
        
        switch animationType {
        case .hero:
            for subView in heroBrowser.view.subviews {
                subView.alpha = 0
            }
            
            let moveImageView = UIImageView(frame: heroBrowser.heroFrame)
            moveImageView.contentMode = heroBrowser.heroContentMode
            moveImageView.image = originImage
            moveImageView.layer.masksToBounds = true
            moveImageView.layer.cornerRadius = cornerRadius
            heroBrowser.view.insertSubview(moveImageView, aboveSubview: heroBrowser.collectionView)
            UIView.animate(withDuration: 0.2) {
                for subView in heroBrowser.view.subviews {
                    subView.alpha = 1
                }
                moveImageView.frame = moveFrame
                moveImageView.layer.cornerRadius = 0
            } completion: { _ in
                moveImageView.removeFromSuperview()
                transitonContext.completeTransition(true)
                heroBrowser.collectionView.isHidden = false
            }
            break
        }
    }
    
    static func dismiss(transitonContext: UIViewControllerContextTransitioning, animationType: HeroTransitionAnimationType, heroBrowser: HeroBrowser) {
        guard let fromVC = transitonContext.viewController(forKey:.from),
              let toVC = transitonContext.viewController(forKey:.to) else
        {
            transitonContext.completeTransition(true)
            return
        }
        
        var cornerRadius: CGFloat = 0
        guard let cell = heroBrowser.collectionView.cellForItem(at: heroBrowser.currentIndexPath() as IndexPath) as? HeroBrowserCollectionCellProtocol,
              confirmOriginImageViewInfo(convertTo: toVC.view, &cornerRadius, heroBrowser: heroBrowser) else
        {
            UIView.animate(withDuration: 0.2) {
                fromVC.view.alpha = 0
            } completion: { _ in
                transitonContext.completeTransition(true)
            }
            return
        }
        
        let photoImageView = cell.getContainer()
        photoImageView.layer.masksToBounds = true
        
        UIView.animate(withDuration: 0.2) {
            photoImageView.layer.cornerRadius = cornerRadius
            photoImageView.frame = heroBrowser.heroFrame
            for subView in heroBrowser.view.subviews {
                subView.alpha = 0
            }
        } completion: { _ in
            transitonContext.completeTransition(true)
        }
    }
    
    private static func confirmOriginImageViewInfo(convertTo toView: UIView, _ cornerRadius: inout CGFloat, heroBrowser: HeroBrowser) -> Bool {
        guard let heroImageView = heroBrowser.heroImageView, case .some = heroImageView.image,
              let oSuperview = heroImageView.superview else {
                  return false
              }
        let heroFrame = oSuperview.convert(heroImageView.frame, to: toView)
        if heroFrame.size == .zero {
            return false
        }
        heroBrowser.heroFrame = heroFrame
        heroBrowser.heroImage = heroImageView.image
        heroBrowser.heroContentMode = heroImageView.contentMode
        cornerRadius = heroImageView.layer.cornerRadius
        return true
    }
    
    /// 一半的差值
    private static func HalfDiffValue(_ superValue: CGFloat, _ subValue: CGFloat) -> CGFloat {
        (superValue - subValue) * 0.5
    }
    
}
