//
//  VideoPlayLIstViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit
import ObjectMapper

private let videoCellIdentifier = "videoCellIdentifier"

class VideoPlayLIstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var videoList: VideoListModel?
    private let activityIndicator = {
        return UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    }()
    private lazy var myTableView: UITableView = {
       
        return UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height), style: UITableViewStyle.Plain)
    }()
    
    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.backgroundColor = UIColor.whiteColor()
        myTableView.showsVerticalScrollIndicator = false
        myTableView.showsHorizontalScrollIndicator = false
        myTableView.separatorColor = UIColor.grayColor()
        myTableView.registerClass(VideoListCell.self, forCellReuseIdentifier: videoCellIdentifier)
        myTableView.tableFooterView = UIView()
        
        self.view.addSubview(myTableView)
        self.activityIndicator.frame = CGRectMake(0, 0, 60, 60)
        self.activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func requestDataFromURL() -> Void {
        
        XRRequest.getWithCodeString(CODE_VIDEOLIST) { [weak self](dict, error) in
            
            if let weakSelf = self {
                weakSelf.activityIndicator.stopAnimating()
                if error == nil {
                    
                    if let retDict = dict {
                        weakSelf.videoList = Mapper<VideoListModel>().map(retDict)
                        weakSelf.myTableView.reloadData()
                    }else {
                        print("数据为空!")
                    }
                }else {
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.requestDataFromURL()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let model = videoList where model.videoList != nil {
            return model.videoList!.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier) as? VideoListCell
        
        if  cell == nil {
            cell = VideoListCell(style: .Default, reuseIdentifier: videoCellIdentifier)
        }
        
        cell?.selectionStyle = .None
        if let model = videoList where model.videoList != nil {
            let video = model.videoList![indexPath.row]
            cell!.configVideoCellWithModel(video)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return VideoListCell.cellHeight()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let model = videoList where model.videoList != nil {
            let video = model.videoList![indexPath.row]
            let videoDetailVc = VideoPlayViewController()
            video.m3u8_url = "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"
            videoDetailVc.videoURL = video.m3u8_url
            videoDetailVc.videoDescription = video.description
            videoDetailVc.video = video
            self.navigationController?.pushViewController(videoDetailVc, animated: true)
        }
    }
    
    
}
