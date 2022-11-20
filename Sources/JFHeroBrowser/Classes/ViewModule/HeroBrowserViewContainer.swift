//
//  HeroBrowserView.swift
//  Example
//
//  Created by 逸风 on 2021/8/4.
//

import Foundation
import UIKit

public protocol HeroBrowserCollectionCellProtocol: UICollectionViewCell {
    typealias UpdatedContainerScaleBlock = (CGFloat) -> Void
    typealias CloseBlock = () -> Void
    static func identify() -> String
    
    var viewModule: HeroBrowserViewModule? { get set }
    var videoViewModule: HeroBrowserVideoViewModule? { get set }
    
    var beginFrame: CGRect { get set }
    var beginTouchPoint : CGPoint { get set }
    var updatedContainerScaleBlock: UpdatedContainerScaleBlock? { get set }
    var closeBlock: CloseBlock? { get set }
    
    func getContainer() -> UIView
    func resetZoom()
    func doubleTap(location: CGPoint)
}

extension HeroBrowserCollectionCellProtocol {
    func resetZoom() {}
    func doubleTap(location: CGPoint) {}
}

