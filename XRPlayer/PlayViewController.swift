//
//  PlayViewController.swift
//  XRPlayer
//
//  Created by xuran on 2019/11/12.
//  Copyright © 2019 xuran. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController, XRPlayerPlaybackDelegate {

    private var playerView: XRPlayer!
    private var isHiddenStatusBar: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.setupPlayer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerView.addRemoteControlEvents()
        playerView.setAVAudioSessionActive(isActive: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.playerView.shutDown()
        self.playerView.setAVAudioSessionActive(isActive: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func setupPlayer() {
        
        guard let url = URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") else {
            return
        }
        
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
    }
    
    // MARK: - 屏幕旋转控制 (默认是竖屏)
    override var shouldAutorotate: Bool {
        return false
        
    }

    // MARK: - XRPlayerPlaybackDelegate
    func playerPlaybackProgressDidChaned(progress: Double) {
        
    }
    
    func playerPlayStatusDidPlaying() {
        
    }
    
}
