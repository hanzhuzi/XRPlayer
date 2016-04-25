//
//  XRVideoPlayer.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief AVFoundation封装视频播放器
 *  
 *  @by    黯丶野火
 **/

import UIKit
import Foundation
import AVFoundation

let bottomViewHeight: CGFloat = 35.0

class XRVideoPlayer: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var bottomView: XRVideoToolBottomView!
    private var isPlaying: Bool = false
    private var loadingView: XRActivityInditor?
    private var portraintFrame: CGRect?
    lazy private var keyWindow: UIWindow = {
        
        return UIApplication.sharedApplication().keyWindow!
    }()
    var videoURL: String?
    private var isFull: Bool = false
    
    deinit {
        self.player?.removeTimeObserver(self)
        self.removePlayerItemObserve(playerItem!)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, videoURL: String) {
        super.init(frame: frame)
        
        self.videoURL = videoURL
        if let vURL =  self.videoURL where !vURL.isEmpty {
            if vURL.hasPrefix("http://") || vURL.hasPrefix("https://") || vURL.hasPrefix("rtsp://") {
                let httpURL = NSURL(string: vURL)
                playerItem = AVPlayerItem(URL: httpURL!)
            }else {
                let localURL = NSURL(fileURLWithPath: vURL)
                let asset = AVAsset(URL: localURL)
                playerItem = AVPlayerItem(asset: asset)
            }
            player = AVPlayer(playerItem: playerItem!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.bounds
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.layer.addSublayer(playerLayer!)
            
            self.observePlayerPlayTime()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.videoPlayToEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            self.observePlayerItemPlayStatus(playerItem!)
            
            loadingView = XRActivityInditor(frame: CGRectMake(0, 0, 60, 60))
            loadingView?.center = center
            self.addSubview(loadingView!)
            loadingView?.startAnimation()
        }
        
        bottomView = XRVideoToolBottomView(frame: CGRectMake(0, CGRectGetMaxY(self.bounds) - bottomViewHeight, CGRectGetWidth(self.frame), bottomViewHeight))
        bottomView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(bottomView)
        bottomView.playButtonClickClosure = { [weak self]() -> Void in
            if let weakSelf = self {
                if let videoPlayer = weakSelf.player {
                    if videoPlayer.rate == 0.0 {
                        videoPlayer.play()
                        videoPlayer.rate = 1.0
                        weakSelf.bottomView.setPlayButtonState(true)
                        weakSelf.isPlaying = true
                    }else {
                        videoPlayer.pause()
                        videoPlayer.rate = 0.0
                        weakSelf.bottomView.setPlayButtonState(false)
                        weakSelf.isPlaying = false
                    }
                }
            }
        }
        
        bottomView.rotationOrientationClosure = {[weak self]() -> () in
            if let weakSelf = self {
                if weakSelf.isFull {
                    weakSelf.orientationPortraintScreen()
                }else {
                    weakSelf.orientationRightFullScreen()
                }
            }
        }
        
        bottomView.sliderValueChangedClosure = { [weak self](value) -> () in
            if let weakSelf = self {
                if let item = weakSelf.playerItem {
                    weakSelf.pauseVideoPlay()
                    let secconds = CMTimeGetSeconds(item.duration) * Float64(value)
                    weakSelf.seekTimeToPlay(Int64(secconds), toPlay: true)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func videoPlayToEnd() -> Void {
        
        print("播放完成")
        seekTimeToPlay(0, toPlay: false)
        bottomView.setPlayButtonState(false)
    }
    
    // 默认是加载完后播放
    func seekTimeToPlay(value: Int64, toPlay: Bool = true) -> Void {
        
        if let videoPlayer = player {
            self.pauseVideoPlay()
            videoPlayer.seekToTime(CMTimeMake(value, 1), completionHandler: { (finished) in
                if finished {
                    if toPlay && self.isPlaying {
                        self.playVideo()
                    }
                }
            })
        }
    }
    
    func pauseVideoPlay() -> Void {
        if let videoPlayer = player {
            videoPlayer.pause()
            videoPlayer.rate = 0.0
        }
    }
    
    func playVideo() -> Void {
        
        if let videoPlayer = player {
            videoPlayer.play()
            videoPlayer.rate = 1.0
        }
    }
    
    func playVideoWithURL(videoURL: String) -> Void {
        
        self.videoURL = videoURL
        
        if playerItem != nil {
            self.removePlayerItemObserve(playerItem!)
        }
        
        if let vURL =  self.videoURL where !vURL.isEmpty {
            if vURL.hasPrefix("http://") || vURL.hasPrefix("https://") || vURL.hasPrefix("rtsp://") {
                let httpURL = NSURL(string: vURL)
                playerItem = AVPlayerItem(URL: httpURL!)
            }else {
                let localURL = NSURL(fileURLWithPath: vURL)
                let asset = AVAsset(URL: localURL)
                playerItem = AVPlayerItem(asset: asset)
            }
        }
        
        player?.replaceCurrentItemWithPlayerItem(playerItem)
        playVideo()
        
        self.observePlayerItemPlayStatus(playerItem!)
    }
    
    // 左旋转屏幕，全屏播放
    func orientationRightFullScreen() -> Void {
        
        if !isFull {
            portraintFrame = self.frame
        }
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
        UIApplication.sharedApplication().setStatusBarOrientation(.LandscapeRight, animated: true)
        
        UIView.animateWithDuration(0.3, animations: { [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.frame = weakSelf.keyWindow.bounds
            }
            }) { [weak self](finish) in
                if let weakSelf = self {
                    weakSelf.layoutIfNeeded()
                    weakSelf.isFull = true
                }
        }
    }
    
    func orientationPortraintScreen() -> Void {
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        UIApplication.sharedApplication().setStatusBarOrientation(.Portrait, animated: true)
        UIView.animateWithDuration(0.3, animations: { [weak self] () -> Void in
            if let weakSelf = self {
                weakSelf.frame = weakSelf.portraintFrame!
            }
            }) { [weak self](finish) in
                if let weakSelf = self {
                    weakSelf.layoutIfNeeded()
                    weakSelf.isFull = false
                }
        }
    }
    
    // 监听播放器的播放进度
    func observePlayerPlayTime() -> Void {
        
        let playerItem = player?.currentItem
        if let item = playerItem {
            player?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { [weak self](time) in
                if let weakSelf = self {
                    let currentTime = CMTimeGetSeconds(time)
                    let duration = CMTimeGetSeconds(item.duration)
                    weakSelf.bottomView.setStartTimeWithSecconds(Double(currentTime))
                    weakSelf.bottomView.setEndTimeWithSecconds(Double(isnan(duration) ? 0.0 : duration))
                    let prencent = isnan(duration) ? 0.0 : currentTime / duration
                    weakSelf.bottomView.setSliderProgress(prencent)
                }
            })
        }
    }
    
    // 监听AVPlayerItem
    func observePlayerItemPlayStatus(playerItem: AVPlayerItem) -> Void {
        
        // 监听状态
        playerItem.addObserver(self, forKeyPath: "status", options: [.New, .Old], context: nil)
        // 监听网络加载状况
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.New, .Old], context: nil)
    }
    
    // 移除AVPlaerItem的监听
    func removePlayerItemObserve(playerItem: AVPlayerItem) -> Void {
        
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = self.bounds
        bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - bottomViewHeight, CGRectGetWidth(self.frame), bottomViewHeight)
        bottomView.layoutIfNeeded()
    }
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        let playerItem = object as? AVPlayerItem
        
        if let path = keyPath {
            if path == "status" {
                // 状态
                if let changeValue = change where changeValue.count > 0 {
                    let playStatus = AVPlayerItemStatus(rawValue: changeValue["new"]!.integerValue)
                    if let status = playStatus {
                        switch status {
                        case .ReadyToPlay:
                            if let item = playerItem {
                                bottomView.setEndTimeWithSecconds(CMTimeGetSeconds(item.duration))
                            }
                            if player?.rate == 1.0 {
                                loadingView?.stopAnimation()
                                bottomView.setPlayButtonState(false)
                                isPlaying = false
                            }
                            
                        case .Failed:
                            print("error: \(player?.error?.localizedDescription)")
                            bottomView.setPlayButtonState(false)
                            isPlaying = false
                        case .Unknown:
                            print("error: \(player?.error?.localizedDescription)")
                            bottomView.setPlayButtonState(false)
                            isPlaying = false
                        }
                    }
                }
            }else if path == "loadedTimeRanges" {
                // 加载进度
                if let item = playerItem {
                    let timeArray = item.loadedTimeRanges
                    let timeRange = timeArray.first?.CMTimeRangeValue
                    if let tRange = timeRange {
                        let startRange = CMTimeGetSeconds(tRange.start)
                        let durationRange = CMTimeGetSeconds(tRange.duration)
                        let totalRange = startRange + durationRange
                        let precent = totalRange / CMTimeGetSeconds(item.duration)
                        bottomView.setProgress(Float(precent))
                        // 加载时的播放处理
                        if let videoPlayer = player {
                            print("rate: \(videoPlayer.rate)")
                            if videoPlayer.rate == 0.0 {
                                videoPlayer.pause() // 暂停播放
                                bottomView.setPlayButtonState(false)
                                isPlaying = false
                                if !loadingView!.isAnimating {
                                    loadingView?.startAnimation()
                                }else {
                                    videoPlayer.prerollAtRate(1.0, completionHandler: { (finish) in
                                        if finish {
                                            self.playVideo()
                                        }
                                    })
                                }
                            }else {
                                if isPlaying {
                                    self.playVideo()
                                    bottomView.setPlayButtonState(true)
                                }else {
                                    self.pauseVideoPlay()
                                    bottomView.setPlayButtonState(false)
                                }
                                loadingView?.stopAnimation()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}



