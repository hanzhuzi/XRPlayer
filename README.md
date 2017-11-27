# XRVideoPlayer-master
基于AVPlayer封装的视频播放器，支持横竖屏切换，支持快进快退，支持Http Live Streamming

# Requirements
* iOS      8.0+
* Xcode  9.0+

# Supports
iOS 8.0+
Swift 3.2

# Component
* Request: [Alamofire](https://github.com/Alamofire/Alamofire)
* Layout : [SnapKit](https://github.com/SnapKit)
* JSON   : [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* Mapping: [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)
* Loading: [DGActivityIndicatorView](https://github.com/gontovnik/DGActivityIndicatorView)

# Usage

```Swift

deinit {
    self.playerView?.releaseVideoPlayer()
    self.playerView = nil
    debugPrint("VideoPlayViewController is dealloc")
}

func setupPlayerView(_ videoURL: String) {

    playerView = XRVideoPlayer(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 260), videoURL: videoURL, isLocalResource: isLocalResource)
    self.view.addSubview(playerView!)
    playerView?.changedOrientationClosure = {[weak self]   (isFull) -> () in
        if let weakSelf = self {
            weakSelf.isFull = isFull
            weakSelf.descripTextView?.isHidden = weakSelf.isFull
        }
    }
}

let videoDetailVc = VideoPlayViewController()
video.title = video.title ?? ""
videoDetailVc.videoURL = video.m3u8_url
videoDetailVc.videoDescription = video.description
videoDetailVc.video = video
self.navigationController?.pushViewController(videoDetailVc, animated: true)
```
