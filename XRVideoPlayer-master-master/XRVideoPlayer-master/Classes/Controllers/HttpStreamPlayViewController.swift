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
    
    fileprivate lazy var tvListArray: [[String]] = []
    
    func requestAndParseTVList() {
        
        // TODO: 加载网络播放列表
        
        if let tvFilePath = Bundle.main.path(forResource: "httpLive", ofType: "m3u8") {
            do {
                let textString = try String(contentsOfFile: tvFilePath, encoding: String.Encoding.utf8)
                var liveResoucelistArray = textString.components(separatedBy: CharacterSet(charactersIn: "["))
                for index in 0 ..< liveResoucelistArray.count {
                    if index < liveResoucelistArray.count {
                        let item = liveResoucelistArray[index]
                        if item.isEmpty {
                            liveResoucelistArray.remove(at: index)
                        }
                    }
                }
                
                for index in 0 ..< liveResoucelistArray.count {
                    let item = liveResoucelistArray[index]
                    var liveList = item.components(separatedBy: CharacterSet(charactersIn: "\n"))
                    if liveList.count > 0 {
                        var item = liveList[0]
                        item = item.substring(to: item.index(of: Character("]"))!)
                        liveList[0] = item
                    }
                    
                    for _index in 0 ..< liveList.count {
                        if _index < liveList.count {
                            let item = liveList[_index]
                            if item.isEmpty {
                                liveList.remove(at: _index)
                            }
                        }
                    }
                    self.tvListArray.append(liveList)
                    self.myTableView.reloadData()
                }
            }
            catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "流媒体列表"
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        myTableView.tableFooterView = UIView()
        
        self.requestAndParseTVList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tvListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section < tvListArray.count {
            let list = tvListArray[section]
            return list.count - 1
        }
        return 0
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
        
        if indexPath.section < self.tvListArray.count {
            let liveList = self.tvListArray[indexPath.section]
            if indexPath.row < liveList.count - 1 {
                let liveText = liveList[indexPath.row + 1]
                if liveText.contains(Character(",")) {
                    let arr = liveText.components(separatedBy: CharacterSet(charactersIn: ","))
                    let tvChannel = arr[0]
                    cell?.textLabel?.text = tvChannel
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = VideoModel()
        if indexPath.section < self.tvListArray.count {
            let liveList = self.tvListArray[indexPath.section]
            if indexPath.row < liveList.count - 1 {
                let liveText = liveList[indexPath.row + 1]
                if liveText.contains(Character(",")) {
                    let arr = liveText.components(separatedBy: CharacterSet(charactersIn: ","))
                    if arr.count > 1 {
                        let tvTitle = arr[0]
                        let tvURLStr = arr[1]
                        var url = tvURLStr
                        if tvURLStr.contains(Character("#")) {
                            let tvURLArray = tvURLStr.components(separatedBy: CharacterSet(charactersIn: "#"))
                            url = tvURLArray[0] // 默认使用第一个播放源
                        }
                        else {
                            url = tvURLStr
                        }
                        video.m3u8_url = url.urlEncoding()
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
        }
    }
    
    // section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        header.backgroundView?.backgroundColor = UIColor.gray
        
        let textLbl = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.frame.size.width, height: 40))
        textLbl.textAlignment = .left
        textLbl.textColor = UIColor.darkText
        textLbl.font = UIFont.boldSystemFont(ofSize: 16)
        header.addSubview(textLbl)
        
        if section < self.tvListArray.count {
            let liveList = self.tvListArray[section]
            if liveList.count > 0 {
                let channel = liveList[0]
                textLbl.text = channel
            }
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
