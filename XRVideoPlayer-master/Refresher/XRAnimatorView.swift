//
//  XRAnimatorView.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 17/6/22.
//  Copyright © 2017年 黯丶野火. All rights reserved.
//

import UIKit

class XRAnimatorView: UIView {
    
    lazy var activity: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        activity.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.addSubview(activity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class XRAnimator: UIView, PullToRefreshViewDelegate  {
    
    var animatorView: XRAnimatorView!
    static let defaultViewHeight: CGFloat = 60
    var customInsetHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animatorView = XRAnimatorView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.addSubview(animatorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshViewHeight() -> CGFloat {
        
        if customInsetHeight > 0 {
            return customInsetHeight
        }
        return XRAnimator.defaultViewHeight
    }
    
    // MARK: - PullToRefreshViewDelegate
    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        animatorView.activity.startAnimating()
    }
    
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        animatorView.activity.stopAnimating()
    }
    
    func pullToRefresh(_ view: PullToRefreshView, progressDidChange progress: CGFloat) {
        debugPrint("progress: \(progress)")
    }
    
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .loading:
            animatorView.activity.startAnimating()
        case .pullToRefresh:
            animatorView.activity.startAnimating()
        case .releaseToRefresh:
            animatorView.activity.startAnimating()
        default:
            break
        }
    }
    
}


