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
        myTableView.registerClass(VideoListCell.self, forCellReuseIdentifier: videoCellIdentifier)
        myTableView.tableFooterView = UIView()
        
        self.view.addSubview(myTableView)
    }
    
    func requestDataFromURL() -> Void {
        
        XRRequest.getWithCodeString(CODE_VIDEOLIST) { [weak self](dict, error) in
            
            if let weakSelf = self {
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
        return 200.0
    }
}
