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
        
        playerView = XRVideoPlayer(frame: CGRectMake(0, 0, self.view.bounds.width, 250), videoURL: videoURL, isLocalResource: false)
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
//        videoURL = "http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"
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
    
        // back more action.
        if let playView = playerView {
            playView.navigationBar.backButtonClosure = { [weak self]() -> Void in
                if let weakSelf = self {
                    if weakSelf.isFull {
                        // 退出全屏
                        playView.orientationPortraintScreen()
                    }else {
                        weakSelf.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
            
            playView.navigationBar.moreButtonClosure = { () -> Void in
                
            }
        }
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
    
    // 在App前后台切换时不允许旋转到其他方向，即保持屏幕方向不变.
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .LandscapeRight
    }
    
    // 强制旋转屏幕
    override func shouldAutorotate() -> Bool {
        return false
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
