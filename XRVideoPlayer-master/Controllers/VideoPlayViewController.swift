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
    var video: VideoModel?
    
    let backBtn: UIButton = {
        
        return UIButton(type: .custom)
    }()
    
    let moreBtn: UIButton = {
        
        return UIButton(type: .custom)
    }()
    
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
    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.RGBColor(255, g: 255, b: 255, a: 1.0)
//        videoURL = "http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"
        if let url = videoURL {
            setupPlayerView(url)
        }
        
        if let descrip = videoDescription {
            descripTextView = UITextView(frame: CGRect(x: 10.0, y: playerView!.frame.maxY + 10.0, width: self.view.frame.width - 20.0, height: 100.0), textContainer: nil)
            descripTextView?.backgroundColor = UIColor.white
            descripTextView?.textColor = UIColor.black
            descripTextView?.font = UIFont.systemFont(ofSize: 15.0)
            descripTextView?.textAlignment = .left
            descripTextView?.isEditable = false
            descripTextView?.isSelectable = false
            descripTextView?.text = descrip
            if let playView = playerView {
                playView.navigationBar?.titleLabel.text = video?.title
                self.view.insertSubview(descripTextView!, belowSubview: playView)
            }else {
                self.view.addSubview(descripTextView!)
            }
        }
    
        // back more action.
        if let playView = playerView {
            playView.navigationBar?.backButtonClosure = { [weak self]() -> Void in
                if let weakSelf = self {
                    if weakSelf.isFull {
                        // 退出全屏
                        weakSelf.playerView?.orientationPortraintScreen()
                    }else {
                        let _ = weakSelf.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            playView.navigationBar?.moreButtonClosure = { () -> Void in
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
//        XRVideoDownloader().downloadVideo(videoURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    // 在App前后台切换时不允许旋转到其他方向，即保持屏幕方向不变.
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    // 强制旋转屏幕
    override var shouldAutorotate : Bool {
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
