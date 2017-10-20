//
//  DownloadViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/21.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

fileprivate let cellID = "tableViewCellID"

class DownloadViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "下载"
        
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.reloadDownloadList), name: NSNotification.Name(rawValue: NNKEY_DOWNLOAD_ADD_TO_LIST), object: nil)
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        XRFileDownloader.shared.downloadProgressClosure = { [unowned self](downloadModelArray) in
            // 进度更新
            XRFileDownloader.shared.downloadModelArray = downloadModelArray
            self.myTableView.reloadData()
        }
        
        XRFileDownloader.shared.downloadFinishedClosure = { [unowned self](downloadModelArray , location) in
            // 下载完成
            XRFileDownloader.shared.downloadModelArray = downloadModelArray
            self.myTableView.reloadData()
            debugPrint("location: \(location)")
            for model in XRFileDownloader.shared.downloadModelArray {
                // 下载完成将临时文件保存到需要保存的目录中.
                if let resp = model.fileDownloadTask?.response , let fileName = resp.suggestedFilename {
                    let saveFilePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first?.appendingFormat("/%@", fileName)
                    do {
                        if let savePath = saveFilePath {
                            let _ = try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: savePath))
                            model.filePath = savePath
                            debugPrint("保存文件\(savePath)成功!")
                        }
                    }
                    catch let error {
                        debugPrint("error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /**
     - 刷新列表
     */
    func reloadDownloadList() {
        myTableView.reloadData()
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
        return XRFileDownloader.shared.downloadModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        }
        
        let model = XRFileDownloader.shared.downloadModelArray[indexPath.row]
        cell?.textLabel?.text = model.title
        cell?.detailTextLabel?.text = "speed: \(String(format: "%.2fKB/s", model.speed))  progress: \(model.progress * 100)%"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = XRFileDownloader.shared.downloadModelArray[indexPath.row]
        if let task = model.fileDownloadTask {
            if task.state == .running {
                XRFileDownloader.shared.suspendDownload(urlString: model.urlString)
            }
            else if task.state == .suspended {
                XRFileDownloader.shared.resumeDownload(urlString: model.urlString)
            }
            else if task.state == .completed {
                debugPrint("任务已经下载完成了")
                debugPrint("filePath -> \(model.filePath ?? "文件路径不存在了!")")
                if let path = model.filePath {
                    let videoDetailVc = VideoPlayViewController()
                    videoDetailVc.videoURL = path
                    videoDetailVc.isLocalResource = true
                    self.navigationController?.pushViewController(videoDetailVc, animated: true)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
