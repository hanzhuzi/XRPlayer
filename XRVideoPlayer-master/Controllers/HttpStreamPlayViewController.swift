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
    
    lazy var tvArray: [[String: String]] = [
        ["title" : "CCTV-6 电影频道", "url" : "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"],
        ["title" : "Capital TV", "url" : "http://ooyalahd2-f.akamaihd.net/i/globalradio01_delivery@156521/master.m3u8"],
        ["title" : "Heart tv", "url" : "http://ooyalahd2-f.akamaihd.net/i/globalradio02_delivery@156522/master.m3u8"],
        ["title" : "TVB-J2", "url" : "http://live1.ms.tvb.com/tvb/tv/j2/04/prog_index.m3u8"],
        ["title" : "TVB新闻", "url" : "http://live1.ms.tvb.com/tvb/tv/inews/044.m3u8"],
        ["title" : "TVB高清", "url" : "http://live1.ms.tvb.com/tvb/tv/jade/044.m3u8"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
