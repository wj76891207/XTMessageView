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


