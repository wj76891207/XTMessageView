//
//  XTWave.swift
//  XTMessageView
//
//  Created by wangjian on 16/05/2018.
//  Copyright © 2018 wangjian. All rights reserved.
//

import UIKit

public struct XTWave {
    private var items: [XTWaveItem] = []
    
    init(withItemsNumber num: Int) {
        items = Array(repeating: XTWaveItem(), count: num)
    }
}

/// 单个波纹的信息
public struct XTWaveItem {
    
    /// 振幅，用于控制波纹的高度，取值范围为[0.0, 1.0]，值越大，幅度越大，波纹高度越高
    var amplitude: Float = 0.0
    
    /// 波纹颜色
    var color: UIColor = UIColor.white
    
    /// 位置，0表示正中间的位置，负数表示向左偏移的位置，正数表示向右偏移的位置，值越大偏移越大
    var location: Int = 0
}
