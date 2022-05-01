//
//  Hero.swift
//  Example
//
//  Created by 逸风 on 2021/8/4.
//

import Foundation
import UIKit
import JRBaseKit

public enum JFHeroBrowserOption {
    case enableBlurEffect(Bool)
    case heroView(UIImageView)
    case imageDidChangeHandle(HeroBrowser.ImagePageDidChangeHandle)
}

public struct Hero<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

struct HeroError: Error {
    let errorMsg: String
}

public protocol HeroCompatible {}
public extension HeroCompatible {
    static var hero: Hero<Self>.Type {
        set {}
        get { Hero<Self>.self }
    }
    var hero: Hero<Self> {
        set {}
        get { Hero(self) }
    }
}


