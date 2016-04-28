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
    var descripTextView: UITextView?
    var isFull: Bool = false
    var videoURL: String?
    var videoDescription: String?
    
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
            // 旋转屏幕执行动画改变子控件的frame
            if let weakSelf = self {
                weakSelf.isFull = isFull
                
            }
        }
    }
    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.RGBColor(255, g: 255, b: 255, a: 1.0)
        
        if let url = videoURL {
            setupPlayerView(url)
        }
        
        if let descrip = videoDescription {
            descripTextView = UITextView(frame: CGRectMake(10.0, CGRectGetMaxY(playerView!.frame) + 10.0, self.view.frame.width - 20.0, 100.0), textContainer: nil)
            descripTextView?.backgroundColor = UIColor.whiteColor()
            descripTextView?.textColor = UIColor.blackColor()
            descripTextView?.font = UIFont.systemFontOfSize(15.0)
            descripTextView?.textAlignment = .Left
            descripTextView?.editable = false
            descripTextView?.selectable = false
            descripTextView?.text = descrip
            if let playView = playerView {
                self.view.insertSubview(descripTextView!, belowSubview: playView)
            }else {
                self.view.addSubview(descripTextView!)
            }
        }
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
    
    override func shouldAutorotate() -> Bool {
        
        return true
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
