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
    
    var wavesView: [XTWaveView] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let styles: [XTWaveView.Style] = [.stripe, .halo, .brick, .pillar]
        let styles: [XTWaveView.Style] = [.brick]
        
        for i in 0 ..< styles.count {
            let waveView = XTWaveView(frame: CGRect(x: 0, y: 50 + CGFloat(i)*120, width: view.bounds.width, height: 100), style: styles[i])
            view.addSubview(waveView)
            wavesView.append(waveView)
        }
        
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            for waveView in self.wavesView {
                waveView.addWave()
            }
//        }
    }
}

