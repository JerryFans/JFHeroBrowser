# JFHeroBrowser

[![Version](https://img.shields.io/cocoapods/v/JFHeroBrowser.svg?style=flat)](https://cocoapods.org/pods/JFHeroBrowser)
[![License](https://img.shields.io/cocoapods/l/JFHeroBrowser.svg?style=flat)](https://cocoapods.org/pods/JFHeroBrowser)
[![Platform](https://img.shields.io/cocoapods/p/JFHeroBrowser.svg?style=flat)](https://cocoapods.org/pods/JFHeroBrowser)
![Language](https://img.shields.io/badge/language-Swift-DE5C43.svg?style=flat)

![](https://github.com/JerryFans/JFHeroBrowser/raw/master/preview1.gif)

## Usage

JFHeroBrowser is not include any network image cache framework(like Kingfisher or SDWebImage). So first step, you should implement NetworkImageProvider Protocol func downloadImage().

example use Kingfisher

```

extension HeroNetworkImageProvider: NetworkImageProvider {
    func downloadImage(with imgUrl: String, complete: Complete<UIImage>?) {
        KingfisherManager.shared.retrieveImage(with: URL(string: imgUrl)!, options: nil) { receiveSize, totalSize in
            guard totalSize > 0 else { return }
            let progress:CGFloat = CGFloat(CGFloat(receiveSize) / CGFloat(totalSize))
            complete?(.progress(progress))
        } downloadTaskUpdated: { task in

        } completionHandler: { result in
            switch result {
            case .success(let loadingImageResult):
                complete?(.success(loadingImageResult.image))
                break
            case .failure(let error):
                complete?(.failed(error))
                break
            }
        }
    }
}

class HeroNetworkImageProvider: NSObject {
    @objc static let shared = HeroNetworkImageProvider()
}

```

And then setup Global Config in App DidFinish.

```

JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroNetworkImageProvider.shared

```


Finally, enjoy JFHeroBrowser.

example code browser a photo list.

```

var list: [HeroBrowserViewModule] = []
        for i in 0..<origins.count {
            list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: thumbs[i], originImgUrl: origins[i]))
        }
        self.hero.browserPhoto(viewModules: list, initIndex: button.tag - 1) {
            [
                .heroView(button.imageView),
                .imageDidChangeHandle({ [weak self] imageIndex in
                    guard let self = self else { return nil }
                    guard let btn = self.view.viewWithTag(imageIndex + 1) as? UIButton else { return nil }
                    return btn.imageView
                }),
            ]
        }

```


## Installation

### CocoasPods

JFHeroBrowser is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JFHeroBrowser', '1.2.0'

```

## Change Log

- v1.0.0 support image (data、UIImage、netowrk image) source & video(local file & network url video) source
- v1.1.0 supoort 'Hero' namespace, add twd quick browser func (browserPhoto & browserVideo)
- v1.2.0 support Horizontal Screen & auto rotate && adapt UI in Horizontal Screen

- v1.3.3 fix iOS16 screen rotate update view frame invalid

## Author

JerryFans, fanjiarong_haohao@163.com

## License

JFHeroBrowser is available under the MIT license. See the LICENSE file for more info.
