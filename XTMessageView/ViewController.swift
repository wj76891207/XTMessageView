//
//  ViewController.swift
//  XTMessageView
//
//  Created by wangjian on 15/05/2018.
//  Copyright © 2018 wangjian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var waveView: XTWaveView = {
        let waveView = XTWaveView(frame: CGRect(x: 0, y: 150, width: view.bounds.width, height: 150))
        return waveView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(waveView)
        self.waveView.addWave()
        
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            self.waveView.addWave()
//        }
    }
}

