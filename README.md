# XRVideoPlayer-master

基于AVPlayer封装的视频播放器，支持横竖屏切换，支持快进快退，支持Http协议视频流

# Requirements
* iOS 8.0+
* Xcode 8.0+
* Swift 3.0

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
        
        playerView = XRVideoPlayer(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250), videoURL: videoURL, isLocalResource: false)
        playerView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.view.addSubview(playerView!)
        playerView?.changedOrientationClosure = {[weak self](isFull) -> () in
            // 旋转屏幕执行动画改变子控件的frame
            if let weakSelf = self {
                weakSelf.isFull = isFull
                weakSelf.descripTextView?.isHidden = weakSelf.isFull
            }
        }
    }
    
    // go to
    let video = VideoModel()
    let tvInfo = tvArray[(indexPath as NSIndexPath).row]
    video.m3u8_url = tvInfo["url"]
    video.description = tvInfo["title"]
    video.title = tvInfo["title"]

    let videoDetailVc = VideoPlayViewController()
    videoDetailVc.videoURL = video.m3u8_url
    videoDetailVc.videoDescription = video.description
    videoDetailVc.video = video
    self.navigationController?.pushViewController(videoDetailVc, animated: true)

```

# Reveal

![](https://github.com/hanzhuzi/XRVideoPlayer-master/blob/master/XRVideoPlayer-master/snaps/snap1.png)
![](https://github.com/hanzhuzi/XRVideoPlayer-master/blob/master/XRVideoPlayer-master/snaps/snap2.png)
![](https://github.com/hanzhuzi/XRVideoPlayer-master/blob/master/XRVideoPlayer-master/snaps/snap3.png)
![](https://github.com/hanzhuzi/XRVideoPlayer-master/blob/master/XRVideoPlayer-master/snaps/snap4.png)

# Future...
