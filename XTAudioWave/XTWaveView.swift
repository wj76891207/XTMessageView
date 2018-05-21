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
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        return displayLink
    }()
    
    private let waveDistance: CGFloat = 5
    private let displayAreaRate: CGFloat = 0.5 // 指定水平方向上用于显示波纹的区域的比例，0.5表示居中的一半区域用于显示
    private var waveMaxNumber: UInt = 8
    private var renderWaveItems: [UInt : XTWaveItem] = [:]
    
    private var waveW: CGFloat = 0
    private var waveH: CGFloat = 0
    
    public init(frame: CGRect, style: Style = .halo) {
        super.init(frame: frame)
        
        self.style = style
        backgroundColor = UIColor.lightGray
        
        // 中间二分之一的区域用于波纹放置点
        waveMaxNumber = UInt(ceil(frame.width*displayAreaRate/waveDistance))
        
        if style == .pillar {
            waveW = pillarWaveW()
        }
        else if style == .brick {
            waveW = brickWaveW()
        }
        else {
            waveW = bounds.height
        }
        waveH = bounds.height/2

        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        displayLink.invalidate()
    }
    
    public func addWave() {
        let position = UInt(arc4random_uniform(UInt32(waveMaxNumber-1)))  // 控制显示的位置
        let amplitude = CGFloat.random(min: 0.1, max: 1) // 生成一个 [0.1, 1] 之间的随机数，作为随机振幅
        
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
            newWaveItem.position = 0//position
            newWaveItem.amplitude = amplitude
            newWaveItem.narrowExp = CGFloat(arc4random_uniform(10)) + 2
            if style == .brick || style == .pillar {
                newWaveItem.color = UIColor.white
            }
            else {
                newWaveItem.color = UIColor.white.withAlphaComponent(CGFloat.random(min: 0.2, max: 0.8))
            }
            
            renderWaveItems[position] = newWaveItem
        }
    }
    
    @objc private func updateWave() {
        let riseStep: CGFloat = 0.1
        let downStep: CGFloat = 0.002
        
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
//                let minAmplitude = style == .brick ? brickMinAmplitude : 0
                let minAmplitude: CGFloat = 0
                if item.curRenderAmplitude <= minAmplitude {
                    removeList.append(position)
                }
            }
        }
        removeList.forEach { renderWaveItems.removeValue(forKey: $0) }
        
        setNeedsDisplay()
    }
}

// MARK: - Draw Wave
extension XTWaveView {
    
    
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setAllowsAntialiasing(true)
        
        if style == .pillar || style == .brick {
            UIColor.white.set()
            let d: CGFloat = 1   // 每条柱子显示区域两边的空隙宽度
            
            // 绘制中间的固定虚线
            context.addPath(middleDash(d))
            context.setLineWidth(1)
            context.strokePath()
        }
        
        for (_, item) in renderWaveItems {
            switch style {
            case .stripe:
                drawStripe(withWaveItem: item)
            case .halo:
                drawHalo(withWaveItem: item)
            case .pillar:
                drawPillar(withWaveItem: item)
            case .brick:
                drawBrick(withWaveItem: item)
            }
        }
    }
    
    /// 获取抛物曲线上指定x的点的实际显示坐标
    private func paraCurvePoint(forOffsetX x: CGFloat,
                                _ position: UInt,
                                _ amplitude: CGFloat,
                                _ narrowExp: CGFloat,
                                _ reverse: Bool) -> CGPoint {
        
        let waveMaxH = waveH
        let waveHW = waveW / 2   // 一半的宽度
        let midX = bounds.width*displayAreaRate/2 + CGFloat(position)*waveDistance
        
        let y = waveMaxH*amplitude*sin(CGFloat.pi*(1+x/waveW) + (reverse ? CGFloat.pi : 0))
        let scaling: CGFloat = pow(1-pow((x-waveHW)/waveHW, 2), narrowExp)
        return CGPoint(x: midX-waveMaxH+x, y: y*scaling+bounds.midY)
    }
    
    /// 根据参数绘制一条抛物曲线，左右两端会以直线方式延长到视图两端
    private func paraCurve(with position: UInt,
                           _ amplitude: CGFloat,
                           _ narrowExp: CGFloat,
                           _ reverse: Bool = false) -> UIBezierPath {

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        stride(from: 0, through: waveW, by: 1).forEach { x in
            let point = paraCurvePoint(forOffsetX: x, position, amplitude, narrowExp, reverse)
            path.addLine(to: point)
        }
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        
        return path
    }
    
    private func drawStripe(withWaveItem item: XTWaveItem) {
        item.color.set()
        
        let path = paraCurve(with: item.position, item.curRenderAmplitude, item.narrowExp)
        
        path.lineWidth = CGFloat.piexlOne
        path.stroke()
    }
    
    private func drawHalo(withWaveItem item: XTWaveItem) {
        item.color.set()
        
        let path = paraCurve(with: item.position, item.curRenderAmplitude, item.narrowExp)
        path.append(paraCurve(with: item.position, item.curRenderAmplitude, item.narrowExp, true))
        
        path.lineWidth = CGFloat.piexlOne
        path.stroke()
        path.fill()
    }
    
    private func drawPillar(withWaveItem item: XTWaveItem) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let d: CGFloat = 1
        
        // 绘制柱条状曲线
        stride(from: 0, to: waveW, by: waveDistance).forEach { x in
            let topPoint = paraCurvePoint(forOffsetX: x+waveDistance/2, item.position, item.curRenderAmplitude, item.narrowExp, false)
            context.addRect(CGRect(x: topPoint.x - waveDistance/2 + d, y: topPoint.y, width: waveDistance-2*d, height: (bounds.midY-topPoint.y)*2))
        }
        context.fillPath()
    }
    
    private func drawBrick(withWaveItem item: XTWaveItem) {
        item.color.set()
        let context = UIGraphicsGetCurrentContext()
        
        let d: CGFloat = 1
        
        // 主体实心的显示块
        let mainBricksPath = CGMutablePath()
//        // 拖尾部分
//        let tailBrickPaths = [CGMutablePath(), CGMutablePath(), CGMutablePath()]
//        let tailNum = tailBrickPaths.count
        
        stride(from: 0, to: waveW, by: waveDistance).forEach { x in
            // 主体部分path绘制
            let topPoint = paraCurvePoint(forOffsetX: x+waveDistance/2, item.position, item.curRenderAmplitude, item.narrowExp, false)
//            var curY = bounds.midY
            if item.curRenderAmplitude >= 0 {
                stride(from: bounds.midY, to: topPoint.y, by: -brickH).forEach { y in
                    if y+brickH/2 >= topPoint.y {
                        mainBricksPath.addRect(CGRect(x: topPoint.x - waveDistance/2 + d, y: y-(brickH-1), width: waveDistance-2*d, height: brickH-1))
                    }
                }
            }
//            else {
//                curY = bounds.midY + floor((topPoint.y-bounds.midY)/brickH)*brickH
//            }
            
//            // 拖尾部分path绘制
//            if item.hasReachTop {
//                let maxTopPoint = paraCurvePoint(forOffsetX: x+waveDistance/2, item.position, item.amplitude, item.narrowExp, false)
//                for i in 0 ..< tailNum {
//                    curY = curY-brickH
//                    if curY > maxTopPoint.y && curY < bounds.midY {
//                        tailBrickPaths[i].addRect(CGRect(x: topPoint.x - waveDistance/2 + d, y: curY+1, width: waveDistance-2*d, height: brickH-1))
//                    }
//                }
//            }
        }
        
        context?.addPath(mainBricksPath)
        context?.fillPath()
        
//        for i in 0 ..< tailNum {
//            context?.addPath(tailBrickPaths[i])
//            context?.setFillColor(UIColor.red.withAlphaComponent(0.7-0.7/CGFloat(tailNum+1)*CGFloat(i)).cgColor)
//            context?.fillPath()
//        }
    }
}

// MARK: - helper
private extension XTWaveView {
    
    func pillarWaveW() -> CGFloat {
        var pillarNum = Int(floorf(Float(bounds.height/waveDistance)))/2
        if pillarNum % 2 == 0 {
            pillarNum -= 1
        }
        return CGFloat(pillarNum) * waveDistance
    }
    
    func brickWaveW() -> CGFloat {
        var pillarNum = Int(floorf(Float(bounds.height/waveDistance)))/2
        if pillarNum % 2 == 0 {
            pillarNum -= 1
        }
        pillarNum = max(1, pillarNum)
        return CGFloat(pillarNum) * waveDistance
    }
    
    var brickH: CGFloat { return 4 }
    
    var brickMinAmplitude: CGFloat {
        return -2*brickH/waveH
    }
    
    func middleDash(_ space: CGFloat) -> CGPath {
        
        let leftSpace = bounds.width*displayAreaRate/2
        let orgX = leftSpace - CGFloat(floorf(Float(leftSpace/waveDistance)))*waveDistance
        let dashPath = CGMutablePath()
        let midY = bounds.midY
        stride(from: orgX, to: bounds.width, by: waveDistance).forEach { x in
            dashPath.move(to: CGPoint(x: x+space, y: midY))
            dashPath.addLine(to: CGPoint(x: x+waveDistance-2*space, y: midY))
        }
        return dashPath
    }
}



/// 单个波纹的信息
public class XTWaveItem {
    
    /// 振幅，用于控制波纹的高度，取值范围为[0.0, 1.0]，值越大，幅度越大，波纹高度越高
    var amplitude: CGFloat = 0.0
    
    var curRenderAmplitude: CGFloat = 0.0
    
    var hasReachTop = false
    
    var narrowExp: CGFloat = 1.0
    
    /// 波纹颜色
    var color: UIColor = UIColor.blue
    
    /// 位置，值越大偏移越大
    var position: UInt = 0
}
