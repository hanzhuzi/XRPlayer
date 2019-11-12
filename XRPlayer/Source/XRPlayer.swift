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
 * @note  基于苹果原生框架AVPlayer封装的视频播放器 (supports mp4, mov, hls(m3u8), avi, mp3)
 *
 * @by    Ran Xu
 */

import UIKit
import Foundation
import AVFoundation
import SnapKit
import MediaPlayer

// Player 播放状态
public enum XRVideoPlayerPlayStatus: Int {
    
    case ready = 1
    case readyToPlay
    case buffering
    case bufferFinished
    case playing
    case pause
    case faild
    case stop
}

// 媒体类型
enum XRMediaType: String {
    case video // 视频
    case audio // 音频
}

// 滑动方向
enum XRPlayerPanHandleDirection: Int {
    case none
    case top_handle
    case bottom_handle
    case left_handle
    case right_handle
}

protocol XRPlayerPlaybackDelegate: class {
    // 播放进度回调
    func playerPlaybackProgressDidChaned(progress: Double)
    // 已经开始播放了
    func playerPlayStatusDidPlaying();
}

private let kPlayerShowToolBarsAnimateTime: TimeInterval = 0.3
private let kPlayerRotateAnimateTime: TimeInterval = 0.3

class XRPlayer: UIView {
    
    private var navigationBar: XPlayerNavigationView = XPlayerNavigationView(frame: CGRect.zero)
    private var bottomToolBar: XRPlayerToolBarView = XRPlayerToolBarView(frame: CGRect.zero)
    private var loadingView: XRCircleStrokeLoadingView = XRCircleStrokeLoadingView(frame: CGRect.zero)
    private var playbackProgressView: XRPlaybackProgressView = XRPlaybackProgressView(frame: CGRect.zero)
    private var coverView: XRPlayerCoverEffectView = XRPlayerCoverEffectView(frame: CGRect.zero)
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: XRAVPlayerItem?
    private var urlAsset: AVURLAsset?
    private var timeObsever: Any?
    private var playerKeyValueObsers: [NSKeyValueObservation] = []
    private var media_type: XRMediaType = .video
    
    // 最后一次缓冲的时长(当前时长+本次缓冲的时长)
    private var lastBufferedTime: Double = 0
    // 每次缓冲预计的最小时长值，已经使用isPlaybackBufferKeeup判断，这里是判断是否已经缓冲+5s的位置了
    private var bufferMaxminSizeDuration: Double = 3
    private var isBuffering: Bool = false
    private var bufferingTimer: Timer?
    private var startBufferringTime: TimeInterval = 0
    
    // 手动拖动的播放时间（未播放时的时间）
    private var seccondsInProgessByHandle: Double = 0
    private var lastProgressByHandle: Float = 0
    private var panHandleDirection: XRPlayerPanHandleDirection = .none
    private var isPlaybackProgressHandled: Bool = false
    
    private var pauseByUser: Bool = false
    private var tapToolViewByUser: Bool = false
    
    private var portraintFrame: CGRect?
    private var isHiddenNavigationAndToolBars: Bool = false
    
    weak var delegate: XRPlayerPlaybackDelegate?
    
    // 是否需要自动播放，当点击播放按钮后即改为`true`
    var isAutoToPlay: Bool = false {
        didSet {
            self.bottomToolBar.rotateButton.isEnabled = isAutoToPlay
        }
    }
    
    // 视频封面图地址
    var coverImageURL: String? {
        
        didSet {
            if coverImageURL != nil  {
                coverView.isHidden = false
                coverView.setCoverImageWithURL(url: coverImageURL, targetSize: self.bounds.size)
            }
        }
    }
    
    // 当前播放视频\音频的标题
    var title: String? {
        didSet {
            self.navigationBar.titleLabel.text = title
        }
    }
    
    // 视频\音频资源地址
    private var url: URL?
    
    var playerOrientationDidChangedClosure: ((_ isFullScreenPlay: Bool) -> ())?
    var playerStatusBarUpdatingAppearceClosure: ((_ isHiddenStatusBar: Bool) -> ())?
    var playerBackButtonActionClosure: (() -> ())?
    
    var isFullScreenPlay: Bool = false
    
    /// 播放器状态
    private var playStatus: XRVideoPlayerPlayStatus = .ready {
        
        didSet {
            DispatchQueue.main.async { [weak self] in
                if let weakSelf = self {
                    switch weakSelf.playStatus {
                    case .bufferFinished:
                        weakSelf.invalidBufferingTimer()
                    case .playing:
                        weakSelf.bottomToolBar.setPlayButtonState(true)
                        weakSelf.bottomToolBar.isAllowDragingSlider = true
                        XRPlayerLog("Player Playing！")
                    case .buffering:
                        weakSelf.bottomToolBar.setPlayButtonState(false)
                        weakSelf.bottomToolBar.isAllowDragingSlider = true
                        weakSelf.loadingView.startAnimationLoading()
                        XRPlayerLog("Player Bufferring！")
                    case .pause:
                        weakSelf.bottomToolBar.setPlayButtonState(false)
                        weakSelf.bottomToolBar.isAllowDragingSlider = true
                        XRPlayerLog("Player Pause！")
                    case .stop:
                        weakSelf.bottomToolBar.setPlayButtonState(false)
                        weakSelf.bottomToolBar.isAllowDragingSlider = false
                        weakSelf.invalidBufferingTimer()
                        XRPlayerLog("Player Stopped！")
                    case .faild:
                        weakSelf.bottomToolBar.setPlayButtonState(false)
                        weakSelf.bottomToolBar.isAllowDragingSlider = false
                        weakSelf.invalidBufferingTimer()
                        weakSelf.bottomToolBar.setPlayButtonIsHidden(isHiddenButton: true)
                        weakSelf.coverView.isHidden = false
                        weakSelf.coverView.state = .loadFaild
                        XRPlayerLog("Player 加载失败了！")
                    case .ready:
                        weakSelf.bottomToolBar.setPlayButtonState(false)
                        weakSelf.bottomToolBar.isAllowDragingSlider = false
                        weakSelf.invalidBufferingTimer()
                        XRPlayerLog("Player ready！")
                        break
                    case .readyToPlay:
                        weakSelf.bottomToolBar.setPlayButtonState(false)
                        weakSelf.bottomToolBar.isAllowDragingSlider = false
                        weakSelf.invalidBufferingTimer()
                        XRPlayerLog("Player readyToPlay！")
                        break
                    }
                }
            }
        }
    }
    
    
    // MARK: - deinit
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
        self.cleanPlayer()
        XRPlayerLog("XRVideoPlayer is dealloc!")
    }
    
    /// Return layerClass AVPlayerLayer class
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.classForCoder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addNotifications()
        
        self.backgroundColor = UIColor.black
        self.clipsToBounds = true
        
        self.setupCoverView()
        self.setupNavigationBar()
        self.setupBottomToolBar()
        self.setupLoadingIndicator()
        self.setupPlaybackProgressView()
        
        self.addGestureRecognizers()
        
        playerLayer = self.layer as? AVPlayerLayer
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer?.backgroundColor = UIColor.black.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, url: URL) {
        self.init(frame: frame)
        
        self.setupPlayerWithURL(url: url)
    }
    
    // 清除Player资源
    private func cleanPlayer() {
        
        self.invalidBufferingTimer()
        self.removePlayerObsevers()
        self.removeRemoteControlTarget()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.player?.pause()
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        self.player = nil
        
        if playerItem != nil {
            self.removePlayerItemObserve(playerItem!)
            playerItem = nil
        }
    }
    
    private func addNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.audioSessionInterraputDidChanged(notifi:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    // layout subViews.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isFullScreenPlay {
            self.portraintFrame = self.frame
        }
    }
    
    // MARK: - getters
    // 音视频总时长
    var totalTime: TimeInterval {
        get {
            if let time = self.playerItem?.duration {
                let duration = CMTimeGetSeconds(time)
                return duration.isNaN ? 0 : duration
            }
            else if let time = self.urlAsset?.duration {
                let duration = CMTimeGetSeconds(time)
                return duration.isNaN ? 0 : duration
            }
            return 0
        }
    }
    
    // 当前播放时长
    var currentTime: TimeInterval {
        get {
            if let time = self.playerItem?.currentTime() {
                let currentSecconds = CMTimeGetSeconds(time)
                return currentSecconds
            }
            return 0
        }
    }
    
    // MARK: - Controls
    private func setupPlayerWithURL(url: URL?) {
        
        self.url = url
        guard let url_ = self.url else {
            return
        }
        
        self.player?.pause()
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        self.removePlayerObsevers()
        self.removePlayerItemObserve(playerItem)
        self.urlAsset = nil
        self.playerItem?.cancelPendingSeeks()
        self.playerItem = nil
        self.playerLayer?.player = nil
        self.player?.cancelPendingPrerolls()
        self.player = nil
        
        self.urlAsset = AVURLAsset(url: url_, options: .none)
        self.playerItem = XRAVPlayerItem(asset: urlAsset!)
        
        OperationQueue().addOperation { [weak self] in
            if let asset = self?.urlAsset {
                self?.asyncLoadValuesWithAssert(asset: asset)
            }
        }
    }
    
    // 初始化AVPlayer
    private func setupAVPlayer(complateBlock: @escaping (() -> Void)) {
        
        if self.media_type == .audio {
            self.coverView.isHidden = false
        }
        else {
            self.coverView.isHidden = true
        }
        
        // 开始缓冲
        self.bufferingSomeSecconds()
        
        self.player = AVPlayer(playerItem: self.playerItem)
        
        self.playerLayer?.player = self.player
        
        self.coverView.state = .playing
        self.bottomToolBar.setPlayButtonIsHidden(isHiddenButton: false)
        
        self.playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        if #available(iOS 10.0, *) {
            self.playerItem?.preferredForwardBufferDuration = 0.0 // defaults
            self.player?.automaticallyWaitsToMinimizeStalling = true // defaults
        } else {
            // Fallback on earlier versions
        }
        
        complateBlock()
    }
    
    private func asyncLoadValuesWithAssert(asset: AVAsset, loadKeys: [String] = ["tracks", "playable", "duration"]) {
        
        asset.loadValuesAsynchronously(forKeys: loadKeys) { [weak self] in
            if let weakSelf = self {
                
                DispatchQueue.main.async {
                    var error: NSError? = nil
                    for key in loadKeys {
                        let status = asset.statusOfValue(forKey: key, error: &error)
                        if status == .failed {
                            weakSelf.playStatus = .faild
                            return
                        }
                    }
                    
                    if !asset.isPlayable {
                        weakSelf.playStatus = .faild
                        return
                    }
                    
                    let duration = CMTimeGetSeconds(asset.duration)
                    
                    weakSelf.bottomToolBar.setStartTimeWithSecconds(0.0)
                    weakSelf.bottomToolBar.setEndTimeWithSecconds(Double(duration))
                    weakSelf.bottomToolBar.setSliderProgress(0.0)
                }
            }
        }
    }
    
    /// 添加时间观察和playItem的播放状态观察
    private func addObseverAndTimeObsever(playItem: XRAVPlayerItem) {
        
        self.addPlayerObsevers()
        self.observePlayerItemPlayStatus(playItem)
    }
    
    // seek to time
    private func seekTimeToPlay(_ time: TimeInterval, complateBlock: @escaping(() -> Void)) {
        
        var stime = time <= 0.0 ? 0.0 : time
        stime = time > totalTime ? totalTime : time
        
        let seekTime = CMTimeMake(value: Int64(stime), timescale: 1)
        self.player?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (finished) in
            if finished {
                complateBlock()
            }
        }
    }
    
    // MARK: - Public Control Methods
    
    // 关机，释放资源
    // 在需要关闭播放器时调用
    public func shutDown() {
        
        self.cleanPlayer()
        self.pause()
        self.playStatus = .stop
        self.playerLayer?.player = nil
        self.player = nil
    }
    
    /// 暂停播放
    public func pause() {
        
        guard let avPlayer = self.player else {
            return
        }
        
        if self.playStatus != .pause {
            avPlayer.pause()
            self.playStatus = .pause
        }
        
        self.updateLockScreenPlayInfo()
    }
    
    /// 播放
    public func play() {
        
        guard let avPlayer = self.player else {
            return
        }
        
        if self.playStatus != .playing {
            avPlayer.play()
            self.playStatus = .playing
        }
        
        self.updateLockScreenPlayInfo()
    }
    
    /// 准备播放
    private func prepareToPlay() {
        
        guard let _ = self.playerItem else {
            return
        }
        
        self.addObservesToPlayerAndToPlay(seekTime: self.seccondsInProgessByHandle)
    }
    
    /// 切换播放资源，开始播放，从头开始播放
    public func playWithURL(url: URL) {
        
        self.playWithURL(url: url, seekTime: 0)
    }
    
    /// 切换播放资源，开始播放，从seekTime位置开始播放
    public func playWithURL(url: URL, seekTime: TimeInterval) {
        
        self.url = url
        self.setupPlayerWithURL(url: url)
        
        if self.isHiddenNavigationAndToolBars {
            self.showNavigationAndToolBars()
        }
        
        if !self.isAutoToPlay {
            self.addObservesToPlayerAndToPlay(seekTime: seekTime)
        }
        else {
            self.addObservesToPlayerAndToPlay(seekTime: seekTime)
        }
    }
    
    // 添加监听并开始播放
    private func addObservesToPlayerAndToPlay(seekTime: TimeInterval) {
        
        guard let playItem = self.playerItem else {
            return
        }
        
        self.setupAVPlayer { [weak self] in
            if let weakSelf = self {
                weakSelf.addObseverAndTimeObsever(playItem: playItem)
                weakSelf.isAutoToPlay = true
                weakSelf.seekTimeToPlay(seekTime) {
                    if weakSelf.playStatus == .readyToPlay {
                        weakSelf.play()
                    }
                }
            }
        }
    }
    
    // 根据当前播放时间更新播放进度
    @discardableResult
    func updatCurrentPlayingProgress() -> Double {
        
        var progress = self.currentTime / self.totalTime
        
        if self.totalTime == 0.0 || self.currentTime > self.totalTime {
            progress = 0.0
        }
        
        progress = progress.isNaN ? 0.0 : progress
        progress = progress <= 0.0 ? 0.0 : progress
        progress = progress >= 1.0 ? 1.0 : progress
        
        DispatchQueue.main.async(execute: { [weak self] in
            if let weakSelf = self {
                weakSelf.bottomToolBar.setStartTimeWithSecconds(weakSelf.currentTime)
                weakSelf.bottomToolBar.setEndTimeWithSecconds(weakSelf.totalTime)
                weakSelf.bottomToolBar.setSliderProgress(progress)
            }
        })
        
        return progress
    }
    
    // 根据拖动进度更新当前播放时间
    @discardableResult
    func updateCurrentPlayingTimeByHandDraging(progress: Float, isPlaybackForword: Bool = true) -> Double {
        
        var progress_ = progress
        progress_ = progress_.isNaN ? 0.0 : progress_
        progress_ = progress_ <= 0.0 ? 0.0 : progress_
        progress_ = progress_ >= 1.0 ? 1.0 : progress_
        
        DispatchQueue.main.async(execute: { [weak self] in
            if let weakSelf = self {
                let curTime = weakSelf.totalTime * Double(progress_)
                weakSelf.bottomToolBar.setStartTimeWithSecconds(curTime)
                weakSelf.bottomToolBar.setEndTimeWithSecconds(weakSelf.totalTime)
                weakSelf.playbackProgressView.setPlaybackProgressWithCurrentTime(currentTime: curTime, totalTime: weakSelf.totalTime, progress: progress_, isPlaybackForword: isPlaybackForword)
                weakSelf.seccondsInProgessByHandle = curTime < 0 ? 0 : curTime
            }
        })
        
        return Double(progress_)
    }
    
}

// MARK: - Player Bufferring
extension XRPlayer {
    
    // 开启Bufferring定时器
    func startBufferingTimer() {
        
        if bufferingTimer == nil {
            bufferingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.bufferingSomeSecconds), userInfo: nil, repeats: true)
            RunLoop.current.add(bufferingTimer!, forMode: RunLoop.Mode.common)
            bufferingTimer?.fireDate = Date.distantPast
            bufferingTimer?.fire()
        }
    }
    
    // 取消Bufferring定时检测
    func invalidBufferingTimer() {
        
        loadingView.stopAnimationLoading()
        if bufferingTimer != nil {
            bufferingTimer?.invalidate()
            bufferingTimer = nil
        }
    }
    
    // 开始缓冲
    @objc private func bufferingSomeSecconds() {
        
        guard let item = self.playerItem else {
            self.playStatus = .faild
            return
        }
        
        // 无法播放的源
        if self.playStatus == .faild {
            return
        }
        
        if self.playStatus == .buffering {
            if item.isPlaybackLikelyToKeepUp {
                // 缓冲OK
                self.isBuffering = false
                self.playStatus = .bufferFinished
                self.invalidBufferingTimer()
                if self.isAutoToPlay && !self.pauseByUser {
                    self.play()
                    self.playStatus = .playing
                }
                else {
                    self.playStatus = .readyToPlay
                }
                XRPlayerLog("缓冲OK，开始播放!")
            }
            else {
                XRPlayerLog("缓冲中...")
                self.startBufferingTimer()
            }
        }
        else {
            
            if self.playStatus != .pause {
                self.pause()
                self.playStatus = .pause
            }
            
            self.playStatus = .buffering
            XRPlayerLog("缓冲中...")
            
            if !self.isBuffering {
                self.loadingView.startAnimationLoading()
                self.isBuffering = true
                self.startBufferringTime = NSDate().timeIntervalSince1970
            }
            
            // 1s轮询一次
            self.startBufferingTimer()
        }
    }
    
}

// MARK: - Observers
extension XRPlayer {
    
    // 监听AVPlayerItem
    private func observePlayerItemPlayStatus(_ playerItem: XRAVPlayerItem) {
        
        // 监听状态
        playerItem.xr_addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        // 监听缓冲进度
        playerItem.xr_addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new], context: nil)
        // 监听缓冲区的数据是否是空了
        playerItem.xr_addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.new], context: nil)
        // 监听缓冲区是否有足够的数据可以播放了
        playerItem.xr_addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
    }
    
    // 移除AVPlaerItem的监听
    private func removePlayerItemObserve(_ playerItem_: XRAVPlayerItem?) {
        
        playerItem_?.xr_removeObserver(self, forKeyPath: "status", context: nil)
        playerItem_?.xr_removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        playerItem_?.xr_removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        playerItem_?.xr_removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
    }
    
    // 监听Player
    private func addPlayerObsevers() {
        
        guard let avPlayer = self.player else {
            return
        }
        
        self.timeObsever = avPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time) in
            if let weakSelf = self {
                let progress = weakSelf.updatCurrentPlayingProgress()
                if weakSelf.delegate != nil {
                    weakSelf.delegate!.playerPlaybackProgressDidChaned(progress: progress)
                }
                
                if weakSelf.delegate != nil {
                    weakSelf.delegate!.playerPlayStatusDidPlaying()
                }
            }
        })
        
        if #available(iOS 10.0, *) {
            
            self.playerKeyValueObsers.append(avPlayer.observe(\.timeControlStatus) { [weak self](object, change) in
                if let weakSelf = self {
                    switch object.timeControlStatus {
                    case .paused:
                        weakSelf.playStatus = .pause
                        break
                    case .playing:
                        weakSelf.playStatus = .playing
                        break
                    case .waitingToPlayAtSpecifiedRate:
                        fallthrough
                    @unknown default:
                        break
                    }
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func removePlayerObsevers() {
        
        if let tObsever = self.timeObsever {
            self.player?.removeTimeObserver(tObsever)
            self.timeObsever = nil
        }
        
        for obsever in self.playerKeyValueObsers {
            obsever.invalidate()
        }
        
        self.playerKeyValueObsers.removeAll()
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let playItem = object as? XRAVPlayerItem else {
            return
        }
        
        if let path = keyPath {
            if path == "status" {
                // 播放状态
                if let changeValue = change , changeValue.count > 0 {
                    let playStatus = XRAVPlayerItem.Status(rawValue: changeValue[NSKeyValueChangeKey.newKey] as! Int)
                    if let status = playStatus {
                        switch status {
                        case .readyToPlay:
                            bottomToolBar.setEndTimeWithSecconds(self.totalTime)
                            self.playStatus = .readyToPlay
                            if self.isAutoToPlay && !self.pauseByUser {
                                self.play()
                            }
                            break
                        case .failed:
                            self.invalidBufferingTimer()
                            self.playStatus = .faild
                            break
                        case .unknown:
                            self.playStatus = .faild
                            break
                        @unknown default:
                            break
                        }
                    }
                }
            }else if path == "loadedTimeRanges" {
                // 加载进度
                let timeArray = playItem.loadedTimeRanges
                let timeRange = timeArray.first?.timeRangeValue
                
                if let tRange = timeRange {
                    // 总缓冲时长
                    let bufferedTime = CMTimeGetSeconds(CMTimeAdd(tRange.start, tRange.duration))
                    if self.lastBufferedTime != bufferedTime {
                        self.lastBufferedTime = bufferedTime
                        
                        let precent = bufferedTime / self.totalTime
                        bottomToolBar.setProgress(Float(precent))
                    }
                }
                
                // 本次缓冲的时长，bufferSizeDuration 预计最小缓冲的时长，如果小于这个时长则继续缓冲
                let passedTime = self.lastBufferedTime <= 0 ? self.currentTime : (self.lastBufferedTime - self.currentTime)
                if passedTime >= self.bufferMaxminSizeDuration || self.lastBufferedTime == self.totalTime || timeArray.first == nil {
                    // 如果可以播放，主动尝试播放
                    if playItem.isPlaybackLikelyToKeepUp {
                        if self.playStatus != .playing {
                            if self.isAutoToPlay && !self.pauseByUser {
                                self.playStatus = .bufferFinished
                                self.invalidBufferingTimer()
                                self.play()
                            }
                        }
                    }
                }
                else {
                    // 缓冲不够，缓冲一段时间
                    if playItem.isPlaybackBufferEmpty {
                        // 缓冲一段时间
                        self.bufferingSomeSecconds()
                    }
                    XRPlayerLog("缓冲不够")
                }
            }
            else if path == "playbackBufferEmpty" {
                // 缓冲空了
                if playItem.isPlaybackBufferEmpty {
                    // 缓冲一段时间
                    self.bufferingSomeSecconds()
                }
            }
            else if path == "playbackLikelyToKeepUp" {
                // 缓冲够了
                if playItem.isPlaybackLikelyToKeepUp {
                    if self.startBufferringTime != 0 && NSDate().timeIntervalSince1970 - self.startBufferringTime < 2 {
                        self.startBufferringTime = 0
                        xrplayer_dispatch_after_in_main(2) {
                            if self.playStatus != .playing {
                                if self.isAutoToPlay && !self.pauseByUser {
                                    self.playStatus = .bufferFinished
                                    self.invalidBufferingTimer()
                                    self.play()
                                }
                            }
                        }
                    }
                    else {
                        if self.playStatus != .playing {
                            if self.isAutoToPlay && !self.pauseByUser {
                                self.invalidBufferingTimer()
                                self.play()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Playback Controls Setup
extension XRPlayer {
    
    private func setupNavigationBar() {
        
        self.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            if xrPlayer_iSiPhoneXSerries() {
                make.height.equalTo(88)
            }
            else {
                make.height.equalTo(64)
            }
        }
        
        navigationBar.clipsToBounds = true
        
        navigationBar.backButtonClosure = { [weak self] in
            if let weakSelf = self {
                if weakSelf.playerBackButtonActionClosure != nil {
                    weakSelf.playerBackButtonActionClosure!()
                }
            }
        }
    }
    
    private func setupBottomToolBar() {
        
        self.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(45)
        }
        
        bottomToolBar.clipsToBounds = true
        bottomToolBar.isAllowDragingSlider = false
        bottomToolBar.setPlayButtonIsHidden(isHiddenButton: true)
        
        bottomToolBar.playButtonClickClosure = { [weak self]() in
            if let weakSelf = self {
                if !weakSelf.isAutoToPlay {
                    weakSelf.isAutoToPlay = true
                    weakSelf.prepareToPlay()
                }
                else {
                    if weakSelf.playStatus != .playing {
                       
                        weakSelf.pauseByUser = false
                        weakSelf.isAutoToPlay = true
                        weakSelf.play()
                    }else {
                        weakSelf.pauseByUser = true
                        weakSelf.pause()
                    }
                }
            }
        }
        
        bottomToolBar.rotationOrientationClosure = {[weak self]() in
            if let weakSelf = self {
                if weakSelf.isFullScreenPlay {
                    weakSelf.exitFullScreenPlayWithOrientationPortraint()
                }else {
                    weakSelf.enterFullScreenPlayWithOrientationRight()
                }
            }
        }
        
        bottomToolBar.sliderValueChangedClosure = { [weak self](value, events) -> () in
            if let weakSelf = self {
                if events == .touchDown {
                    weakSelf.tapToolViewByUser = true
                    weakSelf.pauseByUser = true
                    weakSelf.lastProgressByHandle = value
                    
                    if weakSelf.playStatus == .playing {
                        weakSelf.playbackProgressView.show()
                        weakSelf.pause()
                    }
                }
                else if events == .valueChanged {
                    weakSelf.updateCurrentPlayingTimeByHandDraging(progress: value, isPlaybackForword: value > weakSelf.lastProgressByHandle)
                    weakSelf.lastProgressByHandle = value
                }
                else if events == .touchUpInside {
                    weakSelf.tapToolViewByUser = false
                    weakSelf.pauseByUser = false
                    weakSelf.lastProgressByHandle = value
                    weakSelf.playbackProgressView.hide()
                    if let item = weakSelf.playerItem {
                        let secconds = CMTimeGetSeconds(item.duration) * Float64(value)
                        if !secconds.isNaN {
                            weakSelf.seccondsInProgessByHandle = secconds
                            weakSelf.seekTimeToPlay(secconds, complateBlock: {
                                if weakSelf.isAutoToPlay {
                                    weakSelf.play()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func setupLoadingIndicator() {
        
        self.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(0)
            make.centerY.equalToSuperview().offset(0)
            make.width.height.equalTo(65)
        }
        
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        loadingView.layer.cornerRadius = 4
        loadingView.layer.masksToBounds = true
        loadingView.loadingSize = 45
        loadingView.loadingLineWidth = 3.0
    }
    
    private func setupCoverView() {
        
        self.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        coverView.playButtonTapClosure = { [weak self](state) in
            if let weakSelf = self {
                if state == .readyToPlay {
                    if !weakSelf.isAutoToPlay {
                        weakSelf.isAutoToPlay = true
                        weakSelf.prepareToPlay()
                        weakSelf.coverView.state = .playing
                        weakSelf.bottomToolBar.setPlayButtonIsHidden(isHiddenButton: false)
                    }
                }
                else if state == .loadFaild { // 重新加载
                    weakSelf.setupPlayerWithURL(url: weakSelf.url)
                    weakSelf.prepareToPlay()
                }
            }
        }
    }
    
    private func setupPlaybackProgressView() {
        
        self.addSubview(self.playbackProgressView)
        playbackProgressView.snp.makeConstraints { (make) in
            make.width.equalTo(144)
            make.height.equalTo(80)
            make.centerY.equalToSuperview().offset(-4)
            make.centerX.equalToSuperview()
        }
        
        playbackProgressView.alpha = 0
        
        playbackProgressView.setPlaybackProgressWithCurrentTime(currentTime: self.currentTime, totalTime: self.totalTime, progress: 0.0, isPlaybackForword: true)
    }
    
}

// MARK: - Action
extension XRPlayer {
    
    @objc func showOrhiddenNavigationAndToolBars() {
        
        if playStatus == .ready || playStatus == .readyToPlay {
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hiddenNavigationAndToolBars), object: nil)
        
        if self.isHiddenNavigationAndToolBars {
            self.showNavigationAndToolBars()
        }else {
            self.hiddenNavigationAndToolBars()
        }
    }
    
    // 显示上下toolBars
    func showNavigationAndToolBars() {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hiddenNavigationAndToolBars), object: nil)
        
        navigationBar.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            if xrPlayer_iSiPhoneXSerries() {
                make.height.equalTo(88)
            }
            else {
                make.height.equalTo(64)
            }
        }
        
        bottomToolBar.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(45)
        }
        
        UIView.animate(withDuration: kPlayerShowToolBarsAnimateTime, animations: { [weak self]() -> () in
            if let weakSelf = self {
                weakSelf.layoutIfNeeded()
                weakSelf.navigationBar.alpha = 1.0
                weakSelf.bottomToolBar.alpha = 1.0
                if weakSelf.playerStatusBarUpdatingAppearceClosure != nil {
                    weakSelf.playerStatusBarUpdatingAppearceClosure!(false)
                }
            }
        }, completion: { [weak self](_) in
            if let weakSelf = self {
                weakSelf.isHiddenNavigationAndToolBars = false
                if !weakSelf.tapToolViewByUser && weakSelf.isFullScreenPlay {
                    weakSelf.perform(#selector(weakSelf.hiddenNavigationAndToolBars), with: nil, afterDelay: 5)
                }
            }
        })
    }
    
    // 隐藏上下toolBars
    @objc func hiddenNavigationAndToolBars() {
        
        // 操作toolBar时不隐藏
        if tapToolViewByUser {
            return
        }
        
        navigationBar.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(-89)
            if xrPlayer_iSiPhoneXSerries() {
                make.height.equalTo(88)
            }
            else {
                make.height.equalTo(64)
            }
        }
        
        bottomToolBar.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(47)
            make.height.equalTo(45)
        }
        
        UIView.animate(withDuration: kPlayerShowToolBarsAnimateTime, animations: { [weak self]() -> () in
            if let weakSelf = self {
                weakSelf.layoutIfNeeded()
                weakSelf.navigationBar.alpha = 0.0
                weakSelf.bottomToolBar.alpha = 0.0
                if weakSelf.playerStatusBarUpdatingAppearceClosure != nil {
                    weakSelf.playerStatusBarUpdatingAppearceClosure!(true)
                }
            }
        }, completion: { [weak self](_) in
            if let weakSelf = self {
                weakSelf.isHiddenNavigationAndToolBars = true
            }
        })
    }
    
    // 当播放视频时需要进入后台播放需要将playerLayer的player置空，回到前台时将player设置回playerLayer
    @objc func applicationDidEnterBackground() {
        
        // App挂起，音频进入后台播放，视频则暂停播放
        if self.playStatus == .playing {
            if media_type == .video {
                self.pause()
                self.pauseByUser = true
            }
            else {
                self.updateLockScreenPlayInfo()
                self.playerLayer?.player = nil
            }
        }
    }
    
    @objc func applicationWillEnterForeground() {
        
        self.updateLockScreenPlayInfo()
        self.playerLayer?.player = self.player
        if self.playStatus == .playing {
            if isAutoToPlay {
                self.play()
                self.pauseByUser = false
            }
        }
        else if self.playStatus == .pause {
            // 不自动播放
        }
    }
    
    /// 播放结束
    @objc public func videoPlayToEnd() {
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.playStatus = .stop
                weakSelf.pauseByUser = true
                weakSelf.player?.actionAtItemEnd = .pause
                weakSelf.pause()
                weakSelf.bottomToolBar.setPlayButtonState(false)
                weakSelf.showNavigationAndToolBars()
                
                if weakSelf.isFullScreenPlay {
                    weakSelf.exitFullScreenPlayWithOrientationPortraint()
                }
                
                weakSelf.seekTimeToPlay(0, complateBlock: {
                    // 完成100%
                    if weakSelf.delegate != nil {
                        weakSelf.delegate!.playerPlaybackProgressDidChaned(progress: 1.0)
                    }
                })
            }
        }
    }
}

// MARK: - Rotation
extension XRPlayer {
    
    // radian to angle.
    private func radianToAngle(_ radian: CGFloat) -> CGFloat {
        return radian / CGFloat(Double.pi) * 180.0
    }
    
    // rangle to radian.
    private func angleToRadian(_ rangle: CGFloat) -> CGFloat {
        return rangle / 180.0 * CGFloat(Double.pi)
    }
    
    // 右旋转屏幕，全屏播放
    public func enterFullScreenPlayWithOrientationRight() {
        
        guard let superVw = self.superview else {
            return
        }
        
        if !isFullScreenPlay {
            portraintFrame = self.frame
        }
        
        isFullScreenPlay = true
        bottomToolBar.setRotateButtonStatus(isFullScreenPlay)
        
        superVw.bringSubviewToFront(self)
        
        UIView.animate(withDuration: kPlayerRotateAnimateTime, animations: { [weak self] in
            if let weakSelf = self {
                
                var newFrame = weakSelf.frame
                newFrame.size = CGSize(width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
                weakSelf.frame = newFrame
                weakSelf.center = superVw.center
                
                weakSelf.transform = CGAffineTransform(rotationAngle: weakSelf.angleToRadian(90))
                
                weakSelf.navigationBar
                    .layoutNavigationBarWithISFullScreenPlay(isFullScreen: weakSelf.isFullScreenPlay)
                weakSelf.bottomToolBar
                    .layoutToolBarWithISFullScreenPlay(isFullScreen: weakSelf.isFullScreenPlay)
                
                weakSelf.layoutIfNeeded()
                
                if let closure = weakSelf.playerOrientationDidChangedClosure {
                    closure(weakSelf.isFullScreenPlay)
                }
            }
        }) { [weak self](_) in
            if let weakSelf = self {
                weakSelf.isFullScreenPlay = true
            }
        }
    }
    
    // 竖屏模式
    public func exitFullScreenPlayWithOrientationPortraint() {
        
        isFullScreenPlay = false
        bottomToolBar.setRotateButtonStatus(isFullScreenPlay)
        
        UIView.animate(withDuration: kPlayerRotateAnimateTime, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.transform = CGAffineTransform.identity
                weakSelf.frame = weakSelf.portraintFrame!
                
                weakSelf.navigationBar
                    .layoutNavigationBarWithISFullScreenPlay(isFullScreen: weakSelf.isFullScreenPlay)
                weakSelf.bottomToolBar
                    .layoutToolBarWithISFullScreenPlay(isFullScreen: weakSelf.isFullScreenPlay)
                
                weakSelf.layoutIfNeeded()
                
                if let closure = weakSelf.playerOrientationDidChangedClosure {
                    closure(weakSelf.isFullScreenPlay)
                }
            }
        }) { [weak self](_) in
            if let weakSelf = self {
                weakSelf.isFullScreenPlay = false
            }
        }
    }
    
}

// MARK: - Remote Control
extension XRPlayer {
    
    // 更新播放信息到锁屏
    func updateLockScreenPlayInfo() {
        
        guard let curPlayer = self.player else {
            return
        }
        
        let infoCenter = MPNowPlayingInfoCenter.default()
        
        let playingInfoDict: NSMutableDictionary = NSMutableDictionary()
        
        playingInfoDict.setValue("测试标题", forKey: MPMediaItemPropertyAlbumTitle)
        playingInfoDict.setValue("测试子标题", forKey: MPMediaItemPropertyTitle)
        
        // 设置专辑图片
        if let corerImg = coverView.coverImageView.image {
            let artwork = MPMediaItemArtwork(image: corerImg)
            playingInfoDict.setValue(artwork, forKey: MPMediaItemPropertyArtwork)
        }
        else {
            if let defaultImg = UIImage(named: "icon150") {
                let artwork = MPMediaItemArtwork(image: defaultImg)
                playingInfoDict.setValue(artwork, forKey: MPMediaItemPropertyArtwork)
            }
        }
        
        // 设置播放时长
        playingInfoDict.setValue(self.totalTime, forKey: MPMediaItemPropertyPlaybackDuration)
        playingInfoDict.setValue(self.currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        // 设置播放速率
        playingInfoDict.setValue(curPlayer.rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        
        infoCenter.nowPlayingInfo = playingInfoDict as? [String : Any]
        
        if self.playStatus == .playing {
            if #available(iOS 13.0, *) {
                MPNowPlayingInfoCenter.default().playbackState = .playing
            } else {
                // Fallback on earlier versions
            }
        }
        else if self.playStatus == .pause {
            if #available(iOS 13.0, *) {
                MPNowPlayingInfoCenter.default().playbackState = .paused
            } else {
                // Fallback on earlier versions
            }
        }
        else if self.playStatus == .stop {
            if #available(iOS 13.0, *) {
                MPNowPlayingInfoCenter.default().playbackState = .stopped
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // 添加远程控制
    public func addRemoteControlEvents() {
        
        let command = MPRemoteCommandCenter.shared()
        command.playCommand.isEnabled = true
        command.playCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            if let weakSelf = self {
                weakSelf.play()
            }
            
            return MPRemoteCommandHandlerStatus.success
        }
        
        command.pauseCommand.isEnabled = true
        command.pauseCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            if let weakSelf = self {
                weakSelf.pause()
                weakSelf.pauseByUser = true
            }
            
            return MPRemoteCommandHandlerStatus.success
        }
        
    }
    
    public func removeRemoteControlTarget() {
        
        let command = MPRemoteCommandCenter.shared()
        command.playCommand.isEnabled = false
        command.playCommand.removeTarget(self)
        
        command.pauseCommand.removeTarget(self)
    }
}

// MARK: - UIGestureRecognizers
extension XRPlayer: UIGestureRecognizerDelegate {
    
    private func addGestureRecognizers() {
        
        self.isUserInteractionEnabled = true
        
        let singleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showOrhiddenNavigationAndToolBars))
        singleTapGesture.delegate = self
        singleTapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGestureAction(panGesture:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGestureAction(panGesture: UIPanGestureRecognizer) {
        
        if player == nil || playerItem == nil {
            return
        }
        
        if !(self.playStatus == .playing || self.playStatus == .pause || self.playStatus == .buffering) {
            return
        }
        
        if self.totalTime <= 0 {
            return
        }
        
        var progress: Float = Float(self.currentTime / self.totalTime)
        
        switch panGesture.state {
        case .began:
            let transPoint = panGesture.translation(in: self)
            let abs_x = abs(transPoint.x)
            let abs_y = abs(transPoint.y)
            
            if abs_x > abs_y && (abs_y <= 30) {
                if transPoint.x > 0 {
                    self.panHandleDirection = .right_handle
                }
                else {
                    self.panHandleDirection = .left_handle
                }
                self.playbackProgressView.show()
            }
            else {
                self.playbackProgressView.hide()
            }
            break
        case .changed:
            let transPoint = panGesture.translation(in: self)
            let abs_x = abs(transPoint.x)
//            let abs_y = abs(transPoint.y)
            
            XRPlayerLog("pan changed...")
            
            // 左右滑动
            if self.panHandleDirection == .left_handle || self.panHandleDirection == .right_handle {
                if transPoint.x > 0 {
                    self.panHandleDirection = .right_handle
                }
                else {
                    self.panHandleDirection = .left_handle
                }
                
                self.playbackProgressView.show()
                isPlaybackProgressHandled = true
                XRPlayerLog("左右滑动")
                
                progress = progress.isNaN ? 0.0 : progress
                progress = progress <= 0.0 ? 0.0 : progress
                progress = progress >= 1.0 ? 1.0 : progress
                
                let self_width: CGFloat = 200.0
                
                if self.panHandleDirection == .right_handle {
                    // 右滑
                    let addProgress = Float(abs_x / self_width)
                    
                    progress = progress + addProgress
                    progress = progress.isNaN ? 0.0 : progress
                    progress = progress <= 0.0 ? 0.0 : progress
                    progress = progress >= 1.0 ? 1.0 : progress
                    
                    self.updateCurrentPlayingTimeByHandDraging(progress: progress, isPlaybackForword: true)
                    
                    XRPlayerLog("-> ++\(addProgress) newProgress->\(progress)")
                }
                else {
                    // 左滑
                    let subProgress = Float(abs_x / self_width)
                    
                    progress = progress - subProgress
                    progress = progress.isNaN ? 0.0 : progress
                    progress = progress <= 0.0 ? 0.0 : progress
                    progress = progress >= 1.0 ? 1.0 : progress
                    
                    self.updateCurrentPlayingTimeByHandDraging(progress: progress, isPlaybackForword: false)
                    
                    XRPlayerLog("-> --\(subProgress) newProgress->\(progress)")
                }
            }
            else {
                // 上下滑动
                if transPoint.y > 0 {
                    self.panHandleDirection = .bottom_handle
                }
                else {
                    self.panHandleDirection = .top_handle
                }
                
                XRPlayerLog("上下滑动")
            }
            
            break
        case .cancelled:
            self.playbackProgressView.hide()
            break
        case .ended:
            self.playbackProgressView.hide()
            
            if isPlaybackProgressHandled {
                if !self.seccondsInProgessByHandle.isNaN {
                    self.seekTimeToPlay(self.seccondsInProgessByHandle, complateBlock: { [weak self] in
                        if let weakSelf = self {
                            if weakSelf.isAutoToPlay {
                                weakSelf.play()
                            }
                        }
                    })
                }
            }
            
            break
        case .possible:
            self.playbackProgressView.hide()
            break
        default:
            break
        }
        
    }
    
    // MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let localPoint = gestureRecognizer.location(in: gestureRecognizer.view)
        
        if bottomToolBar.frame.contains(localPoint) || navigationBar.frame.contains(localPoint) {
            tapToolViewByUser = true
            return false
        }
        else {
            tapToolViewByUser = false
            return true
        }
    }
}

// MARK: - AudioSession
extension XRPlayer {
    
    func setAVAudioSessionActive(isActive: Bool) {
        
        // 设置支持后台播放音频
        if isActive {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
                try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            }
            catch let err {
                XRPlayerLog("err-> \(err.localizedDescription)")
            }
        }
        else {
            // not active
            self.pause()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.13) {
                do {
                    try AVAudioSession.sharedInstance().setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
                }
                catch let err {
                    XRPlayerLog("err-> \(err.localizedDescription)")
                }
            }
        }
        
    }
    
    // 音频中断处理
    @objc func audioSessionInterraputDidChanged(notifi: Notification) {
        
        guard let userInfo = notifi.userInfo ,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt ,
            let type = AVAudioSession.InterruptionType.init(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            // 中断开始
            if self.playStatus == .playing {
                self.pause()
            }
        }
        else if type == .ended {
            // 中断结束
            if self.playStatus == .pause {
                self.play()
            }
        }
    }
    
}

// MARK: - AVPlayerItem
class XRAVPlayerItem: AVPlayerItem {
    
    private var keypath_list: [String] = []
    
    /// Safely KVO
    func xr_addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
        
        let firstIdx = keypath_list.firstIndex(of: keyPath)
        if firstIdx == nil {
            keypath_list.append(keyPath)
            super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
        }
    }
    
    func xr_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        
        if let idx = keypath_list.firstIndex(of: keyPath) {
            keypath_list.remove(at: idx)
            super.removeObserver(observer, forKeyPath: keyPath)
        }
    }
    
    func xr_removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?) {
        
        if let idx = keypath_list.firstIndex(of: keyPath) {
            keypath_list.remove(at: idx)
            
            super.removeObserver(observer, forKeyPath: keyPath, context: context)
        }
    }
    
}
