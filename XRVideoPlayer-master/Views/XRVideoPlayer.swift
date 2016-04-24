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

let bottomViewHeight: CGFloat = 30.0

class XRVideoPlayer: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var bottomView: XRVideoToolBottomView!
    private var loadingView: UIActivityIndicatorView?
    var videoURL: String?
    
    
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
            self.observePlayerItemPlayStatus(playerItem!)
            
            loadingView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            loadingView?.center = center
            self.addSubview(loadingView!)
            loadingView?.startAnimating()
        }
        
        bottomView = XRVideoToolBottomView(frame: CGRectMake(0, CGRectGetMaxY(self.bounds) - bottomViewHeight, CGRectGetWidth(self.frame), bottomViewHeight))
        bottomView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(bottomView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVideo() -> Void {
        
        if let videoPlayer = player {
            videoPlayer.play()
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
        
        player = AVPlayer(playerItem: playerItem!)
        playVideo()
        
        self.observePlayerItemPlayStatus(playerItem!)
    }
    
    // 监听播放器的播放进度
    func observePlayerPlayTime() -> Void {
        
        let playerItem = player?.currentItem
        if let item = playerItem {
            player?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { (time) in
                let currentTime = CMTimeGetSeconds(time)
                let duration = CMTimeGetSeconds(item.duration)
                
                print("当前播放时间： %lf, 总时间： %lf", currentTime, duration)
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
                            print("已经准备开始播放...time: \(CMTimeGetSeconds(playerItem!.duration))")
                            loadingView?.stopAnimating()
                        case .Failed:
                            print("播放失败")
                        case .Unknown:
                            print("未知错误")
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
                        
                        if let videoPlayer = player {
                            print("rate: \(videoPlayer.rate)")
                            if videoPlayer.rate == 0 {
                                if loadingView!.isAnimating() {
                                    loadingView?.startAnimating()
                                }
                            }else {
                                videoPlayer.play()
                                loadingView?.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}



