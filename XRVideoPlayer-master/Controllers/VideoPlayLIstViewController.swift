//
//  VideoPlayLIstViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

private let videoCellIdentifier = "videoCellIdentifier"

class VideoPlayLIstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var videoList: VideoListModel?
    fileprivate let activityIndicator = {
        return UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }()
    fileprivate lazy var myTableView: UITableView = {
       
        return UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), style: UITableViewStyle.plain)
    }()
    
    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.white
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.backgroundColor = UIColor.white
        myTableView.showsVerticalScrollIndicator = false
        myTableView.showsHorizontalScrollIndicator = false
        myTableView.separatorColor = UIColor.gray
        myTableView.register(VideoListCell.self, forCellReuseIdentifier: videoCellIdentifier)
        myTableView.tableFooterView = UIView()
        
        self.view.addSubview(myTableView)
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        self.activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func requestDataFromURL() -> Void {
        
//        XRRequest.getWithCodeString(CODE_VIDEOLIST) { [weak self](dict, error) in
//            
//            if let weakSelf = self {
//                weakSelf.activityIndicator.stopAnimating()
//                if error == nil {
//                    
//                    if let retDict = dict {
//                        weakSelf.videoList = Mapper<VideoListModel>().map(JSONObject: retDict)
//                        weakSelf.myTableView.reloadData()
//                    }else {
//                        print("数据为空!")
//                    }
//                }else {
//                    print(error?.localizedDescription)
//                }
//            }
//        }
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let model = videoList , model.videoList != nil {
            return model.videoList!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: videoCellIdentifier) as? VideoListCell
        
        if  cell == nil {
            cell = VideoListCell(style: .default, reuseIdentifier: videoCellIdentifier)
        }
        
        cell?.selectionStyle = .none
        if let model = videoList , model.videoList != nil {
            let video = model.videoList![(indexPath as NSIndexPath).row]
            cell!.configVideoCellWithModel(video)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return VideoListCell.cellHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let model = videoList , model.videoList != nil {
            let video = model.videoList![(indexPath as NSIndexPath).row]
            let videoDetailVc = VideoPlayViewController()
            video.m3u8_url = "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"
            video.description = "CCTV-6 电影频道"
            video.title = "CCTV-6 电影频道"
            videoDetailVc.videoURL = video.m3u8_url
            videoDetailVc.videoDescription = video.description
            videoDetailVc.video = video
            self.navigationController?.pushViewController(videoDetailVc, animated: true)
        }
    }
    
    
}
