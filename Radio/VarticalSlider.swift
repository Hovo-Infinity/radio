//
//  VarticalSlider.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/11/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

@IBDesignable
class VarticalSlider: UIControl {
    public var maxValue:Float = 1.0;
    public var minValue:Float = 0.0;
    private var _value:Float;
    public var value:Float {
        set {
            if newValue < maxValue {
                _value = newValue
            } else {
                _value = maxValue
            }
        }
        get {
            return _value
        }
    }
    private var trakLayer:CALayer;
    
    required init(coder: NSCoder) {
        _value = 0.5;
        trakLayer = CALayer.init();
        super.init(coder: coder)!;
    }
    
    override init(frame: CGRect) {
        _value = 0.5;
        trakLayer = CALayer.init();
        super.init(frame: frame)
        
//        trackLayer.backgroundColor = UIColor.blueColor().CGColor
//        layer.addSublayer(trackLayer)
//        
//        lowerThumbLayer.backgroundColor = UIColor.greenColor().CGColor
//        layer.addSublayer(lowerThumbLayer)
//        
//        upperThumbLayer.backgroundColor = UIColor.greenColor().CGColor
//        layer.addSublayer(upperThumbLayer)
//        
//        updateLayerFrames()
    }

    override func draw(_ rect: CGRect) {
        _ = UIBezierPath(roundedRect: rect, cornerRadius: 1);
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let pos = touch.location(in: self);
        value = Float(pos.x);
        return true;
    }

}
