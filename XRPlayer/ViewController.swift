//
//  ViewController.swift
//  XRPlayer
//
//  Created by xuran on 2019/11/12.
//  Copyright © 2019 xuran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func playAction(_ sender: Any) {
        
        let playCtrl = PlayViewController()
        self.navigationController?.pushViewController(playCtrl, animated: true)
    }
    

}

