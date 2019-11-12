//
//  XRToast.swift
//  QukeMechanic
//
//  Created by 徐冉 on 2019/8/19.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit

private let kToastViewTag: Int = 38033

class XRToast: UIView {
    
    var toast: String?
    var toast_edeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private var messageLbl: UILabel = UILabel(frame: CGRect.zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.addSubview(messageLbl)
        messageLbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(toast_edeInsets.left)
            make.top.equalToSuperview().offset(toast_edeInsets.top)
            make.height.greaterThanOrEqualTo(10)
            make.right.equalToSuperview().offset(-toast_edeInsets.right)
        }
        
        messageLbl.textColor = UIColor.white
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 14)
        messageLbl.numberOfLines = 0
        
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func showWithAnimate() {
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.alpha = 1
                weakSelf.transform = .identity
            }
        }) { (_) in
            
        }
    }
    
    func hideWithAnimate() {
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.alpha = 0
                weakSelf.transform = .identity
            }
        }) { [weak self] (_) in
            if let weakSelf = self {
                weakSelf.alpha = 0
                weakSelf.removeFromSuperview()
            }
        }
    }
    
    
    public static func showToast(toast: String, toView: UIView, afterDelayForHidden: TimeInterval = 2) {
        
        if let oldToast = toView.viewWithTag(kToastViewTag) {
            oldToast.alpha = 0
            oldToast.removeFromSuperview()
        }
        
        let toastSize = (toast as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
        
        var toastWidth = toastSize.width > toView.frame.size.width ? toView.frame.size.width - 55 : toastSize.width
        if toastWidth < 120 {
            toastWidth = 120
        }
        
        let toastView = XRToast(frame: CGRect(x: 0, y: 0, width: toastWidth, height: toastSize.height + 30))
        
        let toast_edgeInsets = toastView.toast_edeInsets
        
        toastView.frame = CGRect(x: 0, y: 0, width: toastWidth + toast_edgeInsets.left + toast_edgeInsets.right, height: toastSize.height + 20 + toast_edgeInsets.top + toast_edgeInsets.bottom)
        toastView.center = CGPoint(x: toView.bounds.size.width * 0.5, y: toView.bounds.size.height * 0.5)
        toastView.messageLbl.text = toast
        toastView.tag = kToastViewTag
        toView.addSubview(toastView)
        
        toastView.messageLbl.sizeToFit()
        toastView.setNeedsLayout()
        toastView.layoutIfNeeded()
        
        toastView.snp.makeConstraints { (make) in
            make.width.equalTo(toastWidth + toast_edgeInsets.left + toast_edgeInsets.right + 10)
            make.height.equalTo(toastView.messageLbl.frame.size.height + toast_edgeInsets.top + toast_edgeInsets.bottom)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        toastView.showWithAnimate()
        
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + afterDelayForHidden) {
            toastView.hideWithAnimate()
        }
    }

}
