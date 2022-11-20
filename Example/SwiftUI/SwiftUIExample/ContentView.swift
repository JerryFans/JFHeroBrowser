//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by 逸风 on 2022/7/19.
//

import SwiftUI
import Kingfisher
import JFHeroBrowser

let keyWindow = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first

let myAppRootVC : UIViewController? = keyWindow?.rootViewController

let thumbs: [String] = {
    var temp: [String] = []
    for i in 1...20 {
        temp.append("http://image.jerryfans.com/template-\(i).jpg?imageView2/0/w/300")
    }
    return temp
}()

let origins: [String] = {
    var temp: [String] = []
    for i in 1...20 {
        temp.append("http://image.jerryfans.com/template-\(i).jpg")
    }
    return temp
}()

struct ContentView: View {
    
    @State var columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(1..<origins.count, id:\.self) { index in
                        ImageCell(index: index).frame(height: columns.count == 1 ? 300 : 150).onTapGesture {
                            var list: [HeroBrowserViewModule] = []
                            for i in 0..<origins.count {
                                list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: thumbs[i], originImgUrl: origins[i]))
                            }
                            myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                        }
                    }
                }
            }.navigationBarTitle(Text("SwiftUI Example"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImageCell: View {

    var alreadyCached: Bool {
        ImageCache.default.isCached(forKey: url.absoluteString)
    }

    let index: Int
    var url: URL {
        URL(string: thumbs[index])!
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            KFImage.url(url)
                .resizable()
                .onSuccess { r in
                    print("Success: \(self.index) - \(r.cacheType)")
                }
                .onFailure { e in
                    print("Error \(self.index): \(e)")
                }
                .onProgress { downloaded, total in
                    print("\(downloaded) / \(total))")
                }
                .placeholder {
                    HStack {
                        Image(systemName: "arrow.2.circlepath.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(10)
                        Text("Loading...").font(.title)
                    }
                    .foregroundColor(.gray)
                }
                
                .cornerRadius(20)

            Spacer()
        }.padding(.vertical, 12)
    }

}
