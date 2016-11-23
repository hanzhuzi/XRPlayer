//
//  DownloadViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/21.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

fileprivate let cellID = "tableViewCellID"

class DownloadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "下载"
        
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.reloadDownloadList), name: NSNotification.Name(rawValue: NNKEY_DOWNLOAD_ADD_TO_LIST), object: nil)
        
        myTableView.delegate = self
        myTableView.dataSource = self
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
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        }
        
        let model = XRFileDownloader.shared.downloadModelArray[indexPath.row]
        cell?.textLabel?.text = model.title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
