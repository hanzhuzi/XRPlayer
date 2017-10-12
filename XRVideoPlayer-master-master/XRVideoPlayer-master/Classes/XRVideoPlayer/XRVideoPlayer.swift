//
//  XRVideoPlayer.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 * @brief 基于AVPlayer视频播放器
 * 
 * @note  基于苹果原生框架AVPlayer封装的视频播放器，只支持Http live streaming
 *
 * @by    黯丶野火
 */

import UIKit
import Foundation
import AVFoundation

private let bottomViewHeight: CGFloat = 45.0
private let navigationBarHeight: CGFloat = 64.0
private let loadingViewHeight: CGFloat = 60.0

fileprivate enum XRVideoPlayerPlayStatus {
    
    case ready
    case buffering
    case playing
    case pause
    case faild
    case stop
}

class XRVideoPlayer: UIView, UIGestureRecognizerDelegate {
    
    open var player: AVPlayer?
    open var playerLayer: AVPlayerLayer?
    open var playerItem: AVPlayerItem?
    open var bottomView: XRVideoToolBottomView?
    open var navigationBar: XRVideoNavigationView?
    fileprivate var pauseByUser: Bool = false
    fileprivate var tapToolViewByUser: Bool = false
    var isLocalResource: Bool = false
    open var loadingView: XRActivityInditor?
    fileprivate var portraintFrame: CGRect?
    open var hiddenOrShow: Bool = false
    var changedOrientationClosure: ((_ isFull: Bool) -> ())?
    
    lazy fileprivate var keyWindow: UIWindow = {
        
        return UIApplication.shared.keyWindow!
    }()
    var videoURL: String?
    fileprivate var isFull: Bool = false
    
    fileprivate var playStatus: XRVideoPlayerPlayStatus = .buffering {
        
        didSet {
            switch playStatus {
            case .playing:
                bottomView?.setPlayButtonState(true)
                loadingView?.stopAnimation()
                bottomView?.slider.isAllowDraging = true
            case .buffering:
                bottomView?.setPlayButtonState(false)
                loadingView?.startAnimation()
                bottomView?.slider.isAllowDraging = true
            case .pause:
                bottomView?.setPlayButtonState(false)
                loadingView?.stopAnimation()
                bottomView?.slider.isAllowDraging = true
            case .stop:
                bottomView?.setPlayButtonState(false)
                loadingView?.stopAnimation()
                bottomView?.slider.isAllowDraging = false
            case .faild:
                bottomView?.setPlayButtonState(false)
                loadingView?.stopAnimation()
                bottomView?.slider.isAllowDraging = false
            case .ready:
                break
            }
        }
    }
    
    deinit {
        if playerItem != nil {
            self.removePlayerItemObserve(playerItem!)
        }
        debugPrint("XRVideoPlayer is dealloc!")
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, videoURL: String, isLocalResource: Bool) {
        
        self.init(frame: frame)
        
        self.videoURL = videoURL
        self.isLocalResource = isLocalResource
        
        if let vURL =  self.videoURL , !vURL.isEmpty {
            if !isLocalResource {
                // 播放网络资源
                let httpURL = URL(string: vURL)
                let asset = AVAsset(url: httpURL!)
                playerItem = AVPlayerItem(asset: asset)
            }else {
                // 播放本地资源
                let localURL = URL(fileURLWithPath: vURL)
                let asset = AVURLAsset(url: localURL)
                playerItem = AVPlayerItem(asset: asset)
            }
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.bounds
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.layer.addSublayer(playerLayer!)
            playerLayer?.backgroundColor = UIColor.rgbColor(0, g: 0, b: 0, a: 0.95).cgColor
            
            self.observePlayerPlayTime()
            self.observePlayerItemPlayStatus(playerItem!)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.applicationActiveStatusChanged(_:)), name: NSNotification.Name(rawValue: "ApplicationActiveStatusChanged"), object: nil)
        }
        
        navigationBar = XRVideoNavigationView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: navigationBarHeight))
        navigationBar?.backgroundColor = UIColor.rgbColor(10, g: 10, b: 10, a: 0.7)
        self.addSubview(navigationBar!)
        
        bottomView = XRVideoToolBottomView(frame: CGRect(x: 0, y: self.bounds.maxY - bottomViewHeight, width: self.frame.width, height: bottomViewHeight))
        bottomView?.backgroundColor = UIColor.rgbColor(10, g: 10, b: 10, a: 0.7)
        self.addSubview(bottomView!)
        
        loadingView = XRActivityInditor(frame: CGRect(x: 0, y: 0, width: loadingViewHeight, height: loadingViewHeight))
        loadingView?.center = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5 + (navigationBar!.frame.height - bottomView!.frame.height) * 0.5)
        self.addSubview(loadingView!)
        loadingView?.startAnimation()
        
        bottomView?.playButtonClickClosure = { [weak self]() -> Void in
            if let weakSelf = self {
                if let _ = weakSelf.player {
                    if weakSelf.playStatus != .playing {
                        weakSelf.pauseByUser = false
                        weakSelf.playVideo()
                    }else {
                        weakSelf.pauseByUser = true
                        weakSelf.pauseVideoPlay()
                    }
                }
            }
        }
        
        bottomView?.rotationOrientationClosure = {[weak self]() -> () in
            if let weakSelf = self {
                if weakSelf.isFull {
                    weakSelf.orientationPortraintScreen()
                }else {
                    weakSelf.orientationRightFullScreen()
                }
            }
        }
        
        bottomView?.sliderValueChangedClosure = { [weak self](value, events) -> () in
            if let weakSelf = self {
                if events == .touchDown {
                    if weakSelf.playStatus == .playing {
                        weakSelf.pauseVideoPlay() // 先暂停播放，等待用户操作进度完成再播放.
                    }
                }
                else if events == .touchUpInside {
                    if let item = weakSelf.playerItem {
                        let secconds = CMTimeGetSeconds(item.duration) * Float64(value)
                        if !secconds.isNaN {
                            weakSelf.seekTimeToPlay(Int64(secconds), toPlay: true)
                        }
                    }
                }
            }
        }
        
        // tap Gesture
        self.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hiddenOrShowWithAnimated))
        tap.delegate = self
        tap.numberOfTapsRequired = 1 // one tap
        self.addGestureRecognizer(tap)
    }
    
    // destory player
    func releaseVideoPlayer() -> Void {
        
        self.pauseVideoPlay()
        self.bottomView?.removeFromSuperview()
        self.navigationBar?.removeFromSuperview()
        self.loadingView?.removeFromSuperview()
        self.removeFromSuperview()
        if playerItem != nil {
            self.removePlayerItemObserve(playerItem!)
        }
        NotificationCenter.default.removeObserver(self)
        self.playerLayer?.removeFromSuperlayer()
        self.player?.replaceCurrentItem(with: nil)
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        self.player = nil
        self.playerLayer = nil
        self.playerItem = nil
        self.bottomView = nil
        self.navigationBar = nil
        self.loadingView = nil
    }
    
    // layout subViews.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFull {
            playerLayer?.frame = self.bounds
            bottomView?.frame = CGRect(x: 0, y: self.bounds.maxY - bottomViewHeight, width: self.bounds.width, height: bottomViewHeight)
            bottomView?.layoutIfNeeded()
            navigationBar?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: navigationBarHeight)
            navigationBar?.layoutIfNeeded()
            loadingView?.center = CGPoint(x: self.frame.height * 0.5, y: self.frame.width * 0.5 + (navigationBar!.frame.height - bottomView!.frame.height) * 0.5)
            loadingView?.layoutIfNeeded()
        }else {
            playerLayer?.frame = self.bounds
            bottomView?.frame = CGRect(x: 0, y: self.bounds.maxY - bottomViewHeight, width: self.frame.width, height: bottomViewHeight)
            bottomView?.layoutIfNeeded()
            navigationBar?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: navigationBarHeight)
            navigationBar?.layoutIfNeeded()
            loadingView?.center = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5 + (navigationBar!.frame.height - bottomView!.frame.height) * 0.5)
            loadingView?.layoutIfNeeded()
        }
    }
    
    // hidden or show bottomView and navigationBar.
    func hiddenOrShowWithAnimated() {
        
        if !self.hiddenOrShow {
            UIView.animate(withDuration: 0.5, animations: { [weak self]() -> () in
                if let weakSelf = self {
                    weakSelf.navigationBar?.alpha = 0.0
                    weakSelf.bottomView?.alpha = 0.0
                    weakSelf.superview?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
                }, completion: { [weak self](_) in
                    if let weakSelf = self {
                        weakSelf.hiddenOrShow = true
                    }
                })
        }else {
            UIView.animate(withDuration: 0.5, animations: { [weak self]() -> () in
                if let weakSelf = self {
                    weakSelf.navigationBar?.alpha = 1.0
                    weakSelf.bottomView?.alpha = 1.0
                    weakSelf.superview?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
                }, completion: { [weak self](_) in
                    if let weakSelf = self {
                        weakSelf.hiddenOrShow = false
                        let time = DispatchTime.now() + 3.0
                        DispatchQueue.main.asyncAfter(deadline: time, execute: {
                            if !weakSelf.tapToolViewByUser {
                                weakSelf.hiddenOrShowWithAnimated()
                            }
                        })
                    }
                })
        }
    }
    
    func applicationActiveStatusChanged(_ notif: Notification?) -> Void {
        
        if let nf = notif {
            let isActive = nf.object as? Bool
            if let active = isActive {
                if active {
                    // App激活
                    if self.playStatus == .playing {
                        playVideo()
                    }
                }else {
                    // App挂起
                    if self.playStatus == .playing {
                        pauseVideoPlay()
                    }
                }
            }
        }
    }
    
    func videoPlayToEnd() -> Void {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { [weak self] in
            if let weakSelf = self {
                weakSelf.playStatus = .stop
                weakSelf.player?.seek(to: kCMTimeZero)
                weakSelf.bottomView?.setPlayButtonState(false)
            }
        }
    }
    
    // seek to time to play...
    func seekTimeToPlay(_ value: Int64, toPlay: Bool = true) -> Void {
        
        if let videoPlayer = player, let curItem = playerItem {
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(value), curItem.currentTime().timescale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { [weak self](finished) in
                if let weakSelf = self {
                    if finished {
                        if toPlay && weakSelf.playStatus == .pause {
                            weakSelf.playVideo()
                        }
                    }
                }
            })
        }
    }
    
    func pauseVideoPlay() -> Void {
        if let videoPlayer = player , self.playStatus != .pause {
            videoPlayer.pause()
            self.playStatus = videoPlayer.rate >= 1.0 ? .playing : .pause
        }
    }
    
    func playVideo() -> Void {
        
        if let videoPlayer = player , self.playStatus != .playing {
            videoPlayer.play()
            self.playStatus = videoPlayer.rate >= 1.0 ? .playing : .pause
        }
    }
    
    func playVideoWithURL(_ videoURL: String) -> Void {
        
        self.videoURL = videoURL
        
        if playerItem != nil {
            self.removePlayerItemObserve(playerItem!)
        }
        
        if let vURL =  self.videoURL , !vURL.isEmpty {
            if vURL.hasPrefix("http://") || vURL.hasPrefix("https://") || vURL.hasPrefix("rtsp://") || vURL.hasPrefix("mms://") {
                let httpURL = URL(string: vURL)
                playerItem = AVPlayerItem(url: httpURL!)
            }else {
                let localURL = URL(fileURLWithPath: vURL)
                let asset = AVAsset(url: localURL)
                playerItem = AVPlayerItem(asset: asset)
            }
        }
        
        player?.replaceCurrentItem(with: playerItem)
        
        self.observePlayerItemPlayStatus(playerItem!)
    }
    
    // buffering...
    func bufferingSomeSecconds() {
        
        if self.playStatus != .pause {
            self.pauseVideoPlay()
        }
        self.playStatus = .buffering
        
        var isBuffering: Bool = false
        if isBuffering { return }
        debugPrint("开始缓冲...")
        isBuffering = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) { [weak self] in
            if let weakSelf = self {
                debugPrint("缓冲OK")
                weakSelf.playVideo()
                isBuffering = false
                // 若缓冲还不够，则再缓冲一段时间
                if let item = weakSelf.playerItem , !item.isPlaybackLikelyToKeepUp {
                    weakSelf.bufferingSomeSecconds()
                }
            }
        }
        
    }
    
    // MARK: 屏幕旋转控制
    // radian to angle.
    func radianToAngle(_ radian: CGFloat) -> CGFloat {
        return radian / CGFloat(Double.pi) * 180.0
    }
    
    // rangle to radian.
    func angleToRadian(_ rangle: CGFloat) -> CGFloat {
        return rangle / 180.0 * CGFloat(Double.pi)
    }
    
    // 仿射矩阵实现围绕UIView的任一点旋转
    func getCGAffineTransformRotateAroundPoint(_ centerX: CGFloat, centerY: CGFloat, x: CGFloat, y: CGFloat, angle: CGFloat) -> CGAffineTransform {
        /* 计算（x，y）从（0，0）为原点的坐标系变换到（centerX，centerY）的坐标系 */
        let cx = x - centerX
        let cy = y - centerY
        
        var transfrom = CGAffineTransform(translationX: cx, y: cy)
        transfrom = transfrom.rotated(by: angle)
        transfrom = transfrom.translatedBy(x: -cx, y: -cy)
        
        return transfrom
    }
    
    // 右旋转屏幕，全屏播放
    func orientationRightFullScreen() -> Void {
        
        if !isFull {
            portraintFrame = self.frame
        }
        
        // 最好使用旋转单个View配合旋转状态栏的方法进行屏幕旋转，比较容易控制，体验比较好，且大部分的视频播放软件都是采用的这种方式.
        /* UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
         这个方法虽然可以，但是在程序前后台切换时会导致横竖屏的混乱.
         */
        UIApplication.shared.statusBarOrientation = .landscapeRight
        // deprecated in iOS 9.0 latter
        // UIApplication.shared.setStatusBarOrientation(.landscapeRight, animated: true)
        isFull = true
        bottomView?.setRotateButtonStatus(isFull)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.transform = CGAffineTransform(rotationAngle: weakSelf.angleToRadian(90))
                weakSelf.frame = weakSelf.keyWindow.bounds
                weakSelf.bottomView?.frame = CGRect(x: 0, y: weakSelf.bounds.maxY - bottomViewHeight, width: weakSelf.bounds.width, height: bottomViewHeight)
                weakSelf.loadingView?.center = CGPoint(x: weakSelf.bounds.size.width * 0.5, y: weakSelf.bounds.size.height * 0.5)
                if let closure = weakSelf.changedOrientationClosure {
                    closure(weakSelf.isFull)
                }
            }
            }) { [weak self](_) in
                if let weakSelf = self {
                    weakSelf.isFull = true
                    weakSelf.layoutIfNeeded()
                }
        }
    }
    
    // 竖屏模式
    func orientationPortraintScreen() -> Void {
        
        UIApplication.shared.statusBarOrientation = .portrait
        isFull = false
        bottomView?.setRotateButtonStatus(isFull)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { [weak self]() in
            
            if let weakSelf = self {
                weakSelf.transform = CGAffineTransform.identity
                weakSelf.frame = weakSelf.portraintFrame!
                if let closure = weakSelf.changedOrientationClosure {
                    closure(weakSelf.isFull)
                }
            }
            }) { [weak self](_) in
                if let weakSelf = self {
                    weakSelf.layoutIfNeeded()
                    weakSelf.isFull = false
                }
        }
    }
    
    // MARK: 播放器状态和缓冲及播放进度检测
    // 监听播放器的播放进度
    func observePlayerPlayTime() -> Void {
        
        if let videoPlayer = player {
            let playerItem = videoPlayer.currentItem
            if let item = playerItem {
                videoPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue(label: "timer.observe"), using: { [weak self](time) in
                    if let weakSelf = self {
                        let loadedRanges = item.seekableTimeRanges
                        if loadedRanges.count > 0 && item.duration.timescale != 0 {
                            let currentTime = CMTimeGetSeconds(item.currentTime())
                            let totalTime = CGFloat(item.duration.value) / CGFloat(item.duration.timescale)
                            let rate = CGFloat(currentTime) / totalTime
                            DispatchQueue.main.async(execute: {
                                if let urlString = weakSelf.videoURL {
                                    if let _ = urlString.range(of: "m3u8") {
                                        weakSelf.bottomView?.startTimeLbl.text = "--/--"
                                        weakSelf.bottomView?.endTimeLbl.text = "--/--"
                                        weakSelf.bottomView?.setSliderProgress(0)
                                    }
                                    else {
                                        weakSelf.bottomView?.setStartTimeWithSecconds(Double(currentTime))
                                        weakSelf.bottomView?.setEndTimeWithSecconds(Double(totalTime))
                                        weakSelf.bottomView?.setSliderProgress(Double(rate))
                                    }
                                }
                            })
                        }
                    }
                    })
            }
        }
    }
    
    // 监听AVPlayerItem
    func observePlayerItemPlayStatus(_ playerItem: AVPlayerItem) -> Void {
        
        // 监听状态
        playerItem.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
        // 监听缓冲进度
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: nil)
        // 监听缓冲区的数据是否是空了
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.new, .old], context: nil)
        // 监听缓冲区是否有足够的数据可以播放了
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new, .old], context: nil)
    }
    
    // 移除AVPlaerItem的监听
    func removePlayerItemObserve(_ playerItem: AVPlayerItem) -> Void {
        
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let playerItem = object as? AVPlayerItem
        
        if let path = keyPath {
            if path == "status" {
                // 状态
                if let changeValue = change , changeValue.count > 0 {
                    let playStatus = AVPlayerItemStatus(rawValue: changeValue[NSKeyValueChangeKey.newKey] as! Int)
                    if let status = playStatus {
                        switch status {
                        case .readyToPlay:
                            if let item = playerItem {
                                bottomView?.setEndTimeWithSecconds(CMTimeGetSeconds(item.duration))
                            }
                            self.playStatus = .ready
                            self.playVideo()
                        case .failed:
                            debugPrint("加载失败了-> \(player!.error?.localizedDescription)")
                            self.playStatus = .faild
                        case .unknown:
                            debugPrint("未知错误")
                            break
                        }
                    }
                }
            }else if path == "loadedTimeRanges" {
                // 加载进度
                if let item = playerItem {
                    
                    let timeArray = item.loadedTimeRanges
                    let timeRange = timeArray.first?.timeRangeValue
                    if let tRange = timeRange {
                        let startRange = CMTimeGetSeconds(tRange.start)
                        let durationRange = CMTimeGetSeconds(tRange.duration)
                        if startRange.isNaN || durationRange.isNaN {
                            
                        }
                        else {
                            let totalRange = startRange + durationRange
                            let precent = totalRange / CMTimeGetSeconds(item.duration)
                            bottomView?.setProgress(Float(precent))
                        }
                    }
                    if item.isPlaybackLikelyToKeepUp {
                        if let videoPlayer = self.player {
                            self.playStatus = videoPlayer.rate >= 1.0 && !self.pauseByUser ? .playing : .pause
                        }
                    }
                    else {
                        self.pauseVideoPlay()
                        // 缓冲一段时间
                        self.bufferingSomeSecconds()
                    }
                }
            }
            else if path == "playbackBufferEmpty" {
                // 缓冲空了
                if let item = playerItem, item.isPlaybackBufferEmpty {
                    self.pauseVideoPlay()
                    // 缓冲一段时间
                    self.bufferingSomeSecconds()
                }
            }
            else if path == "playbackLikelyToKeepUp" {
                // 缓冲够了
                if let item = playerItem, item.isPlaybackLikelyToKeepUp {
                    if let videoPlayer = self.player {
                        self.playStatus = videoPlayer.rate >= 1.0 && !self.pauseByUser ? .playing : .pause
                    }
                }
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let local = gestureRecognizer.location(in: gestureRecognizer.view)
        if bottomView!.frame.contains(local) {
            tapToolViewByUser = true
            return false
        }
        else {
            tapToolViewByUser = false
            return true
        }
    }
    
    
    
}



