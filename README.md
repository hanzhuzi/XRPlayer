# XRPlayer

基于AVPlayer封装的视频播放器，支持横竖屏切换，支持快进快退，支持Http协议视频流。
The video player based on avplayer package supports horizontal and vertical screen switching, fast forward and backward, and HTTP protocol video stream.

# Requirements
* iOS 9.0+
* Xcode 10+
* Swift 4.2+

# Component
* Layout : [SnapKit](https://github.com/SnapKit)

# Usage
```swift

playerView = XRPlayer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width / 16.0 * 10.0), url: url)
self.view.addSubview(playerView)
playerView.isAutoToPlay = false
playerView.title = "测试标题"

playerView.coverImageURL = ""

playerView.delegate = self

playerView.playerOrientationDidChangedClosure = { [weak self](isFullScreenPlay) in
    if let weakSelf = self {
        weakSelf.isHiddenStatusBar = isFullScreenPlay
        weakSelf.setNeedsStatusBarAppearanceUpdate()
    }
}

playerView.playerBackButtonActionClosure = { [weak self] in
    if let weakSelf = self {
        if weakSelf.playerView.isFullScreenPlay {
            weakSelf.playerView.exitFullScreenPlayWithOrientationPortraint()
        }
        else {
            weakSelf.navigationController?.popViewController(animated: true)
        }
    }
}

```
