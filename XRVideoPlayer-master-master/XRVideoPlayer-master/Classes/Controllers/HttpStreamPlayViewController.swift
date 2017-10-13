//
//  HttpStreamPlayViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/8/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class HttpStreamPlayViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    fileprivate lazy var tvArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "网络流媒体列表"
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        //加载本地直播源地址
        if let tvFilePath = Bundle.main.path(forResource: "httpLive", ofType: "m3u8") {
            do {
                let textString = try String(contentsOfFile: tvFilePath, encoding: String.Encoding.utf8)
                debugPrint(textString)
                self.tvArray = textString.components(separatedBy: CharacterSet(charactersIn: "\n"))
                for index in 0 ..< self.tvArray.count {
                    let text = self.tvArray[index]
                    if text.isEmpty {
                        self.tvArray.remove(at: index)
                    }
                }
                myTableView.reloadData()
            }
            catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        
        myTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        
        
        debugPrint("statusBarFrame: -> \(UIApplication.shared.statusBarFrame) navBarFrame: -> \(self.navigationController?.navigationBar.frame) TabBar: -> \(self.tabBarController?.tabBar.frame)")
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
        
        let tvString = tvArray[(indexPath as NSIndexPath).row]
        if tvString.characters.count > 0 , tvString.contains(Character(",")) {
            let tvTitle = tvString.components(separatedBy: CharacterSet(charactersIn: ",")).first
            cell?.textLabel?.text = tvTitle
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = VideoModel()
        let tvString = tvArray[(indexPath as NSIndexPath).row]
        if tvString.characters.count > 0 , tvString.contains(Character(",")) {
            let tvArr = tvString.components(separatedBy: CharacterSet(charactersIn: ","))
            if tvArray.count > 1 {
                let tvTitle = tvArr[0]
                let tvURLStr = tvArr[1] as String
                var url = tvURLStr
                if tvURLStr.contains(Character("#")) {
                    let tvURLs = tvURLStr.components(separatedBy: CharacterSet(charactersIn: "#"))
                    url = tvURLs[0]
                }
                video.m3u8_url = url
                video.description = tvTitle
                video.title = tvTitle
                let videoDetailVc = VideoPlayViewController()
                videoDetailVc.videoURL = video.m3u8_url
                videoDetailVc.videoDescription = video.description
                videoDetailVc.video = video
                self.navigationController?.pushViewController(videoDetailVc, animated: true)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
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
