//
//  HeroBundleTool.swift
//  HeroBrowser
//
//  Created by 逸风 on 2022/4/24.
//

import UIKit

class HeroBundleTool: NSObject {
    
    static func getBundleImage(with imageName: String, imageType: String = "png") -> UIImage? {
        if let img = UIImage(named: imageName) {
            return img
        }
        if let path = Bundle.main.path(forResource: imageName, ofType: imageType), let image = UIImage(contentsOfFile: path) {
            return image
        }
        guard let frameWorkPath = Bundle.main.path(forResource: "Frameworks", ofType: nil)?.appending("/JFHeroBrowser.framework") else { return nil }
        guard let bundlePath = Bundle(path: frameWorkPath)?.path(forResource: "JFHeroBrowser", ofType: "bundle") else { return nil }
        if let imgPath = Bundle(path: bundlePath)?.path(forResource: imageName + "@2x", ofType: imageType), let image = UIImage(contentsOfFile: imgPath) {
            return image
        }
        return nil
    }
    
}
