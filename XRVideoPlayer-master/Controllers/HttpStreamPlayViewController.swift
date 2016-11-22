//
//  HttpStreamPlayViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/8/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class HttpStreamPlayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    fileprivate lazy var tvArray: [[String: String]] = [
        ["title" : "CCTV-1", "url" : "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"],
        ["title" : "CCTV-6", "url" : "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"],
        ["title" : "Heart tv", "url" : "http://ooyalahd2-f.akamaihd.net/i/globalradio02_delivery@156522/master.m3u8"],
        ["title" : "CCTV-3", "url" : "http://ivi.bupt.edu.cn/hls/cctv3hd.m3u8"],
        ["title" : "TVB新闻", "url" : "http://live1.ms.tvb.com/tvb/tv/inews/044.m3u8"],
        ["title" : "TVB高清", "url" : "http://live1.ms.tvb.com/tvb/tv/jade/044.m3u8"],
        ["title" : "智取威虎山", "url" : "http://jobsfe.funshion.com/play/v1/mp4/BEDECC98539E761F3142FD35B47D3FB5048B938A.mp4?vf=MCw2QTYyRg==&token=Mzc1RDU3MEUzRTlEMUNBQUJCNTNCNTk3ODdBNDcwQ0EzREI5NDIxQ19td2ViXzE0Nzk3MTc1NTM=&fudid=1472179462a661b&app_code=mweb&user_id=0&user_token="],
        ["title" : "少年班", "url" : "http://jobsfe.funshion.com/play/v1/mp4/2C69DDCC6A9897BD08A33B8457D65C8DC21405E8.mp4?vf=MCw1QjAyQg==&token=RTU1REQ4RTg2QTc1OTBDQUUyMDgwNjM4RjU3QURDN0EzOTExMzY5RV9td2ViXzE0Nzk3MjU1MDY=&fudid=1472179462a661b&app_code=mweb&user_id=0&user_token="],
        ["title" : "网络视频03", "url" : "http://baobab.wdjcdn.com/14525705791193.mp4"],
        ["title" : "网络视频04", "url" : "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4"],
        ["title" : "网络视频05", "url" : "http://baobab.wdjcdn.com/1455968234865481297704.mp4"],
        ["title" : "网络视频06", "url" : "http://baobab.wdjcdn.com/1455782903700jy.mp4"],
        ["title" : "网络视频07", "url" : "http://baobab.wdjcdn.com/14564977406580.mp4"],
        ["title" : "网络视频08", "url" : "http://baobab.wdjcdn.com/1456316686552The.mp4"],
        ["title" : "网络视频09", "url" : "http://baobab.wdjcdn.com/1456480115661mtl.mp4"],
        ["title" : "网络视频10", "url" : "http://baobab.wdjcdn.com/1456665467509qingshu.mp4"],
        ["title" : "网络视频11", "url" : "http://baobab.wdjcdn.com/1455614108256t(2).mp4"],
        ["title" : "网络视频12", "url" : "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4"],
        ["title" : "网络视频13", "url" : "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4"],
        ["title" : "网络视频14", "url" : "http://baobab.wdjcdn.com/1456734464766B(13).mp4"],
        ["title" : "网络视频15", "url" : "http://baobab.wdjcdn.com/1456653443902B.mp4"],
        ["title" : "网络视频16", "url" : "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "视频播放列表"
        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTVUrl))
        self.navigationItem.rightBarButtonItems = [rightBarItem]
        
        myTableView.tableFooterView = UIView()
    }
    
    // 动态添加直播地址
    func addTVUrl() {
        
        if #available(iOS 8.0, *) {
            let alertVc: UIAlertController = UIAlertController(title: "请输入您要添加的直播地址(http://协议)", message: "仅支持http协议的直播地址", preferredStyle: .alert)
            
            alertVc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            
            alertVc.addAction(UIAlertAction(title: "添加", style: .default, handler: { (action) in
                if let textFields = alertVc.textFields {
                    let textField = textFields[0]
                    if let url = textField.text, !url.isEmpty {
                        let title = "标题" + url
                        let info: [String : String] = ["title" : title, "url" : url]
                        self.tvArray.append(info)
                        self.myTableView.reloadData()
                    }
                }
            }))
            
            alertVc.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "请输入直播地址"
                textField.font = UIFont.systemFont(ofSize: 14.0)
                textField.textColor = UIColor.black
            })
            
            self.present(alertVc, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tvArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellID")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCellID")
        }
        
        cell?.selectionStyle = .default
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cell?.textLabel?.textColor = UIColor.black
        
        let tvInfo = tvArray[(indexPath as NSIndexPath).row]
        
        cell?.textLabel?.text = tvInfo["title"]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = VideoModel()
        let tvInfo = tvArray[(indexPath as NSIndexPath).row]
        video.m3u8_url = tvInfo["url"]
        video.description = tvInfo["title"]
        video.title = tvInfo["title"]
        
        let videoDetailVc = VideoPlayViewController()
        videoDetailVc.videoURL = video.m3u8_url
        videoDetailVc.videoDescription = video.description
        videoDetailVc.video = video
        self.navigationController?.pushViewController(videoDetailVc, animated: true)
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
