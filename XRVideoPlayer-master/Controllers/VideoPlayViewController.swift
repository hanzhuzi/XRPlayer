//
//  VideoPlayViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class VideoPlayViewController: UIViewController {
    
    var playerView: XRVideoPlayer?
    var topNavView: UIView = UIView()
    var isFull: Bool = false
    var videoURL: String?
    
    let backBtn: UIButton = {
        
        return UIButton(type: .Custom)
    }()
    
    let moreBtn: UIButton = {
        
        return UIButton(type: .Custom)
    }()
    
    func setupPlayerView(videoURL: String) {
        
        playerView = XRVideoPlayer(frame: CGRectMake(0, 0, self.view.frame.width, 240.0), videoURL: videoURL)
        playerView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        self.view.addSubview(playerView!)
        playerView?.playVideo()
        
        playerView?.changedOrientationClosure = {[weak self](isFull) -> () in
            
            if let weakSelf = self {
                weakSelf.isFull = isFull
                weakSelf.topNavView.frame = CGRectMake(0, 0, weakSelf.view.frame.width, 64.0)
                weakSelf.backBtn.frame = CGRectMake(12, 26, 32, 32)
                weakSelf.moreBtn.frame = CGRectMake(CGRectGetMaxX(weakSelf.view.frame) - 32.0 - 12.0, 26, 32, 32)
            }
        }

    }
    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if let url = videoURL {
            setupPlayerView(url)
        }
        
        topNavView.frame = CGRectMake(0, 0, self.view.frame.width, 64.0)
        topNavView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.01)
        
        backBtn.frame = CGRectMake(12, 26, 32, 32)
        backBtn.setImage(UIImage(named: "back"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
        topNavView.addSubview(backBtn)
        
        moreBtn.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - 32.0 - 12.0, 26, 32, 32)
        moreBtn.setImage(UIImage(named: "more"), forState: .Normal)
        moreBtn.addTarget(self, action: #selector(self.moreAction), forControlEvents: .TouchUpInside)
        topNavView.addSubview(moreBtn)
        
        self.view.addSubview(topNavView)
    }
    
    func backAction() -> Void {
        
        if isFull {
            // 退出全屏
            playerView?.orientationPortraintScreen()
        }else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func moreAction() -> Void {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 释放播放器对象
        playerView?.releaseVideoPlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
