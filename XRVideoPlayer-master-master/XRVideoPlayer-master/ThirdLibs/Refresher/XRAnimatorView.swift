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
    var infoLbl: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        infoLbl.frame = CGRect(x: self.frame.size.width * 0.5 - 100 * 0.5 - 30 * 0.5, y: (self.frame.size.height - 30) * 0.5, width: 100, height: 30)
        self.addSubview(infoLbl)
        infoLbl.textColor = UIColor.black
        infoLbl.font = UIFont.systemFont(ofSize: 15)
        infoLbl.textAlignment = .right
        
        activity.frame = CGRect(x: infoLbl.frame.maxX, y: (self.frame.size.height - 30) * 0.5, width: 30, height: 30)
        self.addSubview(activity)
        activity.color = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class XRAnimator: UIView, PullToRefreshViewDelegate  {
    
    var animatorView: XRAnimatorView!
    static let defaultViewHeight: CGFloat = 80
    var customInsetHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        animatorView = XRAnimatorView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(animatorView)
        animatorView.center = self.center
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
        
    }
    
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        animatorView.infoLbl.text = "刷新已完成!"
        animatorView.activity.stopAnimating()
    }
    
    func pullToRefresh(_ view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
    
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .loading:
            animatorView.infoLbl.text = "拼命刷新中..."
            animatorView.activity.startAnimating()
            break
        case .pullToRefresh:
            animatorView.infoLbl.text = "下拉以刷新"
            break
        case .releaseToRefresh:
            animatorView.infoLbl.text = "松手即可刷新"
            break
        }
    }
    
}


