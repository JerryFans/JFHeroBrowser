//
//  ViewController.swift
//  JFHeroBrowser
//
//  Created by fanjiaorng919 on 04/27/2022.
//  Copyright (c) 2022 fanjiaorng919. All rights reserved.
//

import UIKit
import Kingfisher
import UIKit
import Foundation
import MobileCoreServices
import Photos

enum HeroBrowserDemoType: String {
    case localImage = "本地图片"
    case dataImage = "data图片"
    case networkImage = "网络图片(Kingfiser)"
    case networkSDWebImage = "网络图片(SDWebImage)"
    case networkVideo = "同时网络视频+图片"
}

let demoTypes: [HeroBrowserDemoType] = [
    .localImage,
    .dataImage,
    .networkImage,
    .networkSDWebImage,
    .networkVideo,
]

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "JFHeroBrowser Demo"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
}

extension ViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = demoTypes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = type.rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = demoTypes[indexPath.row]
        switch type {
        case .dataImage:
            let vc = DataImageViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
        case .localImage:
            let vc = LocalImageViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
        case .networkImage:
            let vc = NetworkImageViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
        case .networkVideo:
            let vc = NetworkVideoViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .networkSDWebImage:
            let vc = NetworkImageViewController()
            vc.isUseSDWebImage = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

