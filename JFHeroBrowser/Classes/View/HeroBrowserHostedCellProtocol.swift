//
//  HeroBrowserHostedCellProtocol.swift
//  JFHeroBrowser
//
//  Created by WillsonWang on 29/01/2023.
//

import Foundation

public protocol HeroBrowserHostedCellProtocol {
    var videoViewModule: HeroBrowserVideoViewModule? { get set }
    var viewModule: HeroBrowserViewModule? { get set }
}

public protocol HeroBrowserVideoCellProtocol : HeroBrowserHostedCellProtocol {
    func pauseVideo()
    func playVideo()
}
