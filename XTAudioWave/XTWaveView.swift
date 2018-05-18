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
        case halo
        case brick
        case pillar
    }
    public var style = Style.stripe
    
    public enum FlowSpeed {
        case still
        case low
        case middle
        case high
    }
    public var flowSpeed = FlowSpeed.still
    
//    private let displayLink: CADisplayLink = {
//        let displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
//        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
//        return displayLink
//    }()
    
    private let waveDistance: CGFloat = 5
    private var waveMaxNumber: UInt = 8
    private var renderWaveItems: [UInt : XTWaveItem] = [:]
    
    public init(frame: CGRect, style: Style = .stripe) {
        super.init(frame: frame)
        
        self.style = style
        backgroundColor = UIColor.white
        
        // 中间三分之二的区域用于波纹放置点
        waveMaxNumber = UInt(ceil(frame.width*2/3/waveDistance))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addWave() {
        let position = UInt(arc4random_uniform(UInt32(waveMaxNumber-1)))  // 控制显示的位置
        let tmp = CGFloat(drand48())
        let amplitude = tmp + (1-tmp)*0.1 // 生成一个 [0.1, 1] 之间的随机数，作为随机振幅
        
        if let existingItem = renderWaveItems[position] {
            // 根据新的振幅，决定是否要重置wave的顶点
            if (!existingItem.hasReachTop && existingItem.amplitude < amplitude) ||
                (existingItem.hasReachTop && existingItem.curRenderAmplitude < amplitude) {
                
                existingItem.amplitude = amplitude
                existingItem.hasReachTop = false
            }
        }
        else {
            // 创建新的wave
            let newWaveItem = XTWaveItem()
            newWaveItem.position = 20//position
            newWaveItem.amplitude = 0.6//amplitude
            newWaveItem.scaling = 2//CGFloat(arc4random_uniform(10)) + 2
            
            renderWaveItems[position] = newWaveItem
        }
        
        updateWave()
    }
}

// MARK: - Draw Wave
extension XTWaveView {
    
    @objc func updateWave() {
        let riseStep: CGFloat = 0.1
        let downStep: CGFloat = 0.02
        
        var removeList: [UInt] = []
        for (position, item) in renderWaveItems {
            // 到达顶点后，就开始回落
            if item.curRenderAmplitude >= item.amplitude {
                item.hasReachTop = true
            }
            
            if item.hasReachTop == false {
                item.curRenderAmplitude = min(item.amplitude, item.curRenderAmplitude + riseStep)
            } else {
                item.curRenderAmplitude = item.curRenderAmplitude - downStep
                if item.curRenderAmplitude <= 0 {
                    removeList.append(position)
                }
            }
        }
        removeList.forEach { renderWaveItems.removeValue(forKey: $0) }
        
        setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setAllowsAntialiasing(true)
        
        for item in renderWaveItems {
            switch style {
            case .stripe:
                drawStripe(withWaveItem: item.value)
            default:
                break
            }
        }
    }
    
    private func drawStripe(withWaveItem item: XTWaveItem) {
        
        let waveMaxH = bounds.height/2
        let waveW = waveMaxH * 2
        let waveHW = waveMaxH
        let midX = bounds.width/6 + CGFloat(item.position)*waveDistance
        let startX = midX-waveMaxH
        
        item.color.set()
        let wavePath = UIBezierPath()
        wavePath.move(to: CGPoint(x: startX, y: bounds.midY))
        stride(from: 0, to: waveW, by: 1).forEach { x in
            let y = waveMaxH*item.amplitude*sin(CGFloat.pi*(1+x/waveW))
            let scaling: CGFloat = 1-fabs(pow((x-waveHW)/waveHW, item.scaling))
            wavePath.addLine(to: CGPoint(x: x+startX, y: y*scaling+bounds.midY))
        }
        
        wavePath.stroke()
    }
}



/// 单个波纹的信息
public class XTWaveItem {
    
    /// 振幅，用于控制波纹的高度，取值范围为[0.0, 1.0]，值越大，幅度越大，波纹高度越高
    var amplitude: CGFloat = 0.0
    
    var curRenderAmplitude: CGFloat = 0.0
    
    var hasReachTop = false
    
    var scaling: CGFloat = 1.0
    
    /// 波纹颜色
    var color: UIColor = UIColor.blue
    
    /// 位置，值越大偏移越大
    var position: UInt = 0
}
