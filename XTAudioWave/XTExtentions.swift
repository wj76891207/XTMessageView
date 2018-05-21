//
//  XTExtentions.swift
//  XTMessageView
//
//  Created by wangjian on 21/05/2018.
//  Copyright © 2018 wangjian. All rights reserved.
//

import UIKit

var _piexlOne: CGFloat = -1

extension CGFloat {
    
    static var piexlOne: CGFloat {
        if _piexlOne < 0 {
            _piexlOne = 1/UIScreen.main.scale
        }
        return _piexlOne
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return min + (max-min)*CGFloat(drand48())
    }
}
