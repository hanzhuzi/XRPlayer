//
//  VideoPlayViewController.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit

class VideoPlayViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerView = XRVideoPlayer(frame: CGRectMake(0, 0, self.view.frame.width, 200.0), videoURL: "http://7xt95f.com2.z0.glb.qiniucdn.com/job_6e86ae2b08492d1c2d7a2d88e02780be.mp4")
        playerView.backgroundColor = UIColor.blackColor()
        playerView.center = self.view.center
        self.view.addSubview(playerView)
        playerView.playVideo()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
