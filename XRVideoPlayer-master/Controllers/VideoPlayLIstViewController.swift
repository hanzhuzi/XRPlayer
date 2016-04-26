//
//  VideoPlayLIstViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/26.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class VideoPlayLIstViewController: UIViewController {

    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        XRRequest.postWithCodeString(.POST, codeString: "") { (dict, error) in
            
            if error == nil {
                
                if let retDict = dict {
                    print(retDict)
                }
            }else {
                print(error?.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
