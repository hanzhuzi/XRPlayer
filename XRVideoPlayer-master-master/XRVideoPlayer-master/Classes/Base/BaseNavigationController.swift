//
//  BaseNavigationController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/11/18.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController , UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationBar.isTranslucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
