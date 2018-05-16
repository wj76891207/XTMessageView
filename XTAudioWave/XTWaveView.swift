//
//  XTWaveView.swift
//  XTMessageView
//
//  Created by wangjian on 16/05/2018.
//  Copyright © 2018 wangjian. All rights reserved.
//

import UIKit

public class XTWaveView: UIView {
    
    public enum Style {
        case stripe
        case brick
    }
    public var style = Style.stripe
    
    public enum FlowSpeed {
        case still
        case low
        case middle
        case high
    }
    public var flowSpeed = FlowSpeed.still
    
    public var maxWaveItemNumber = 8
    
    private let displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        return displayLink
    }()
    
    private var renderWaveItems: [XTWaveItem] = []
}

// MARK: - Draw Wave
extension XTWaveView {
    
    @objc func updateWave() {
        
    }
    
    public override func draw(_ rect: CGRect) {
        for item in renderWaveItems {
            switch style {
            case .stripe:
                drawStripe(withWaveItem: item)
            default:
                break
            }
        }
    }
    
    private func drawStripe(withWaveItem waveItem: XTWaveItem) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
    }
}
