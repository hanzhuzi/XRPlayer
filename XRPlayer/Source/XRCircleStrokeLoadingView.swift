//
//  XRCircleStrokeLoadingView.swift
//  CircleActivityView
//
//  Created by 徐冉 on 2019/9/16.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit

private let kXRCircleLayerGroupAnimationKey: String = "kXRCircleLayerGroupAnimationKey"
private let kXRCircleLoadingViewTag: Int = 9838

class XRCircleStrokeLoadingView: UIView {

    private var circleLayer: CAShapeLayer = CAShapeLayer()
    private var isAnimateLoading: Bool = false
    
    // loading circle layer's size
    var loadingSize: CGFloat = 28 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // circle layer's width
    var loadingLineWidth: CGFloat = 4.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._setup()
    }
    
    convenience init(frame: CGRect, loadingSize: CGFloat, loadingLineWidth: CGFloat) {
        self.init(frame: frame)
        
        self.loadingSize = loadingSize
        self.loadingLineWidth = loadingLineWidth
    }
    
    private func _setup() {
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.0
        self.alpha = 0
        
        circleLayer.frame = self.bounds
        self.layer.addSublayer(circleLayer)
        
        // layer for laoding
        circleLayer.fillColor = nil
        circleLayer.backgroundColor = nil
        circleLayer.lineWidth = loadingLineWidth
        circleLayer.lineCap = CAShapeLayerLineCap.round
        circleLayer.lineJoin = CAShapeLayerLineJoin.round
        
        // circle path
        let circleLayerBounds = circleLayer.bounds
        if loadingSize > circleLayerBounds.size.width {
            loadingSize = circleLayerBounds.size.width
        }
        
        circleLayer.frame = CGRect(x: 0, y: 0, width: loadingSize, height: loadingSize)
        circleLayer.position = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: circleLayer.bounds.size.width * 0.5, y: circleLayer.bounds.size.height * 0.5),
                                      radius: loadingSize * 0.5 - loadingLineWidth,
                                      startAngle: CGFloat(Double.pi / 180.0 * 0.0),
                                      endAngle: CGFloat(Double.pi / 180.0 * 360.0),
                                      clockwise: true)
        circleLayer.path = circlePath.cgPath
        
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 1.0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // circle path
        let circleLayerBounds = self.bounds
        if loadingSize > circleLayerBounds.size.width {
            loadingSize = circleLayerBounds.size.width
        }
        
        circleLayer.frame = CGRect(x: 0, y: 0, width: loadingSize, height: loadingSize)
        circleLayer.position = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: circleLayer.bounds.size.width * 0.5, y: circleLayer.bounds.size.height * 0.5),
                                      radius: loadingSize * 0.5 - loadingLineWidth,
                                      startAngle: CGFloat(Double.pi / 180.0 * 0.0),
                                      endAngle: CGFloat(Double.pi / 180.0 * 360.0),
                                      clockwise: true)
        circleLayer.path = circlePath.cgPath
    }
    
    // MARK: - Animation Controls
    open func startAnimationLoading() {
        
        if isAnimateLoading {
            return
        }
        
        UIView.animate(withDuration: 0.21, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.alpha = 1.0
            }
        }) { (_) in
            
        }
        
        let strokeEndAnima = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnima.values = [0, 1.0]
        strokeEndAnima.duration = 0.8
        strokeEndAnima.beginTime = 0.0
        
        let strokeStartAnima = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStartAnima.values = [0, 1.0]
        strokeStartAnima.duration = 0.8
        strokeStartAnima.beginTime = 0.8
        
        let rotateAnima = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnima.fromValue = 0
        rotateAnima.toValue = Double.pi * 2.0
        rotateAnima.duration = 1.6
        rotateAnima.beginTime = 0
        
        let animaGroup = CAAnimationGroup()
        animaGroup.duration = 1.6
        animaGroup.repeatCount = HUGE
        animaGroup.isRemovedOnCompletion = false
        animaGroup.autoreverses = false
        animaGroup.fillMode = .forwards
        animaGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        animaGroup.animations = [strokeEndAnima, strokeStartAnima, rotateAnima]
        
        circleLayer.add(animaGroup, forKey: kXRCircleLayerGroupAnimationKey)
        
        circleLayer.speed = 1
        
        isAnimateLoading = true
    }
    
    open func stopAnimationLoading(isNeedRemoved: Bool = false) {
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if let weakSelf = self {
                weakSelf.alpha = 0
            }
        }) { [weak self](_) in
            if let weakSelf = self {
                weakSelf.circleLayer.speed = 0
                weakSelf.circleLayer.removeAnimation(forKey: kXRCircleLayerGroupAnimationKey)
                weakSelf.alpha = 0
                if isNeedRemoved {
                    weakSelf.removeFromSuperview()
                }
            }
        }
        
        isAnimateLoading = false
    }
    
    // MARK: - Public
    /// Show circle loadingView to superView
    @discardableResult
    public static func showCircleLoadingView(to superView: UIView?, loadingSize: CGFloat = 46, loadingLineWidth: CGFloat = 3.5) -> XRCircleStrokeLoadingView {
        
        let superVw: UIView? = superView
        
        if let actingLoadView = superVw?.viewWithTag(kXRCircleLoadingViewTag) {
            actingLoadView.removeFromSuperview()
        }
        
        let loadingViewSize = loadingSize + 10 * 2
        
        let loadingView = XRCircleStrokeLoadingView(frame: CGRect(x: 0, y: 0, width: loadingViewSize, height: loadingViewSize),
                                                            loadingSize: loadingSize,
                                                            loadingLineWidth: loadingLineWidth)
        loadingView.tag = kXRCircleLoadingViewTag
        superVw?.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: loadingView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 0, constant: loadingViewSize)
        let heightConstraint = NSLayoutConstraint(item: loadingView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 0, constant: loadingViewSize)
        loadingView.addConstraints([widthConstraint, heightConstraint])
        
        let centerXConstraint = NSLayoutConstraint(item: loadingView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superVw, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: loadingView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superVw, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0)
        superVw?.addConstraints([centerXConstraint, centerYConstraint])
        
        loadingView.startAnimationLoading()
        
        return loadingView
    }
    
    /// Hide circle loadingView
    public static func hideCircleLoadingView(with superView: UIView?) {
        
        let loadingView = superView?.viewWithTag(kXRCircleLoadingViewTag) as? XRCircleStrokeLoadingView
        loadingView?.stopAnimationLoading(isNeedRemoved: true)
    }

}
