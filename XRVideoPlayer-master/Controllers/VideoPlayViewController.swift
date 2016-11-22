//
//  VideoPlayViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class VideoPlayViewController: UIViewController, XRFileDownloaderDelegate {
    
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
        
        self.view.backgroundColor = UIColor.rgbColor(255, g: 255, b: 255, a: 1.0)
        
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
            
            playView.navigationBar?.downloadButtonClosure = { [weak self]() -> Void in
                if let weakSelf = self {
                    XRFileDownloader.shared.downloadFile(weakSelf.videoURL).delegate = weakSelf
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
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
    
    // MARK: - XRFileDownloaderDelegate
    func downloader(downloadProgress progress: Float, speedOfKB speed: Float, totalSizeOfKB totalSize: Float) {
        debugPrint("progress: \(progress) -- speed: \(speed)KB/s -- totalSize: \(String(format: "%.2f", totalSize / 1024.0))M")
    }
    
    func downloaderFinished(downloadProgress progress: Float, downloadTask: URLSessionDownloadTask, location: URL) {
        // 下载完成将临时文件保存到需要保存的目录中.
        let saveFilePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first?.appendingFormat("/%@", downloadTask.response!.suggestedFilename!)
        do {
            if let savePath = saveFilePath {
                let _ = try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: savePath))
                debugPrint("保存文件\(savePath)成功!")
            }
        }
        catch let error {
            debugPrint("error: \(error.localizedDescription)")
        }
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
