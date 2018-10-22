//
//  DKJoneEXT.swift
//  nameAnima
//
//  Created by 朱德坤 on 2018/10/22.
//  Copyright © 2018 DKJone. All rights reserved.
//

import UIKit

protocol SelfAware: class {
    static func awake()
}

class NothingToSeeHere {
    static func harmlessFunction() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            (types[index] as? SelfAware.Type)?.awake()
        }
        types.deallocate()
    }
}

extension UIApplication {
    private static let runOnce: Void = {
        NothingToSeeHere.harmlessFunction()
    }()

    override open var next: UIResponder? {
        //This will be automatically called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}


extension UIViewController:SelfAware{
    static func awake() {
        swizzleMethod
    }

    private static let swizzleMethod: Void = {
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(swizzled_viewWillAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()

    private static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(forClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) else{return}

        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    @objc func swizzled_viewWillAppear(_ animated: Bool) {
        swizzled_viewWillAppear(animated)
        let g =  UISwipeGestureRecognizer(target: self, action: #selector(dkShow(gestrue:)))
        g.numberOfTouchesRequired = 4
        g.direction = .down
        view.addGestureRecognizer(g)


    }
    @objc func dkShow(gestrue:UISwipeGestureRecognizer){

        let v = DKJoneView(frame: view.frame)
        view.addSubview(v)
        v.addUntitled1Animation { (isEnd) in
            if isEnd { v.removeFromSuperview()}
        }
    }

}




@IBDesignable
class DKJoneView: UIView, CAAnimationDelegate {
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation: Bool = false

    var color: UIColor!
    var color1: UIColor!

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperties()
        setupLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProperties()
        setupLayers()
    }

    func setupProperties() {
        self.color = UIColor(red: 0.97, green: 0.589, blue: 0.577, alpha: 1)
        self.color1 = UIColor(red: 0.992, green: 0.906, blue: 0.609, alpha: 1)
    }

    func setupLayers() {
        self.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.0)

        let dkPath = CAShapeLayer()
        dkPath.frame = CGRect(x: 34.26, y: 266.31, width: 306.48, height: 134.37)
        dkPath.path = dkPathPath().cgPath
        self.layer.addSublayer(dkPath)
        layers["dkPath"] = dkPath

        resetLayerProperties(forLayerIdentifiers: nil)
    }

    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if layerIds == nil || layerIds.contains("dkPath") {
            let dkPath = layers["dkPath"] as! CAShapeLayer
            dkPath.fillColor = nil
            dkPath.strokeColor = UIColor.black.cgColor
        }

        CATransaction.commit()
    }

    // MARK: - Animation Setup

    func addUntitled1Animation(completionBlock: ((_ finished: Bool) -> Void)? = nil) {
        if completionBlock != nil {
            let completionAnim = CABasicAnimation(keyPath: "completionAnim")
            completionAnim.duration = 3.987
            completionAnim.delegate = self
            completionAnim.setValue("Untitled1", forKey: "animId")
            completionAnim.setValue(false, forKey: "needEndAnim")
            layer.add(completionAnim, forKey: "Untitled1")
            if let anim = layer.animation(forKey: "Untitled1") {
                completionBlocks[anim] = completionBlock
            }
        }

        let fillMode: CAMediaTimingFillMode = .forwards

        ////DkPath animation
        let dkPathLineWidthAnim = CAKeyframeAnimation(keyPath: "lineWidth")
        dkPathLineWidthAnim.values = [0.5, 3]
        dkPathLineWidthAnim.keyTimes = [0, 1]
        dkPathLineWidthAnim.duration = 3

        let dkPathStrokeEndAnim = CAKeyframeAnimation(keyPath: "strokeEnd")
        dkPathStrokeEndAnim.values = [0, 1]
        dkPathStrokeEndAnim.keyTimes = [0, 1]
        dkPathStrokeEndAnim.duration = 3
        dkPathStrokeEndAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let dkPathStrokeColorAnim = CAKeyframeAnimation(keyPath: "strokeColor")
        dkPathStrokeColorAnim.values = [UIColor(red: 0.97, green: 0.589, blue: 0.577, alpha: 1).cgColor,
                                        UIColor(red: 0.992, green: 0.906, blue: 0.609, alpha: 1).cgColor]
        dkPathStrokeColorAnim.keyTimes = [0, 1]
        dkPathStrokeColorAnim.duration = 3

        let dkPathLineDashPhaseAnim = CAKeyframeAnimation(keyPath: "lineDashPhase")
        dkPathLineDashPhaseAnim.values = [0, 1]
        dkPathLineDashPhaseAnim.keyTimes = [0, 1]
        dkPathLineDashPhaseAnim.duration = 3

        let dkPathShadowColorAnim = CAKeyframeAnimation(keyPath: "shadowColor")
        dkPathShadowColorAnim.values = [UIColor(red: 0.953, green: 0.506, blue: 0.506, alpha: 1).cgColor,
                                        UIColor(red: 0.988, green: 0.89, blue: 0.541, alpha: 1).cgColor]
        dkPathShadowColorAnim.duration = 3
        let dkPathShadowOpacityAnim = CAKeyframeAnimation(keyPath: "shadowOpacity")
        dkPathShadowOpacityAnim.values = [0.718, 0.8]
        dkPathShadowOpacityAnim.duration = 3

        let dkPathOpacityAnim = CAKeyframeAnimation(keyPath: "opacity")
        dkPathOpacityAnim.values = [1, 0]
        dkPathOpacityAnim.keyTimes = [0, 1]
        dkPathOpacityAnim.duration = 0.987
        dkPathOpacityAnim.beginTime = 3

        let dkPathUntitled1Anim: CAAnimationGroup = DKAHelp.group(animations: [dkPathLineWidthAnim, dkPathStrokeEndAnim, dkPathStrokeColorAnim, dkPathLineDashPhaseAnim, dkPathShadowColorAnim, dkPathShadowOpacityAnim, dkPathOpacityAnim], fillMode: fillMode)
        layers["dkPath"]?.add(dkPathUntitled1Anim, forKey: "dkPathUntitled1Anim")
    }

    // MARK: - Animation Cleanup

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completionBlock = completionBlocks[anim] {
            completionBlocks.removeValue(forKey: anim)
            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool {
                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
            }
            completionBlock(flag)
        }
    }

    func updateLayerValues(forAnimationId identifier: String) {
        if identifier == "Untitled1" {
            DKAHelp.updateValueFromPresentationLayer(forAnimation: layers["dkPath"]!.animation(forKey: "dkPathUntitled1Anim"), theLayer: layers["dkPath"]!)
        }
    }

    func removeAnimations(forAnimationId identifier: String) {
        if identifier == "Untitled1" {
            layers["dkPath"]?.removeAnimation(forKey: "dkPathUntitled1Anim")
        }
    }

    func removeAllAnimations() {
        for layer in layers.values {
            layer.removeAllAnimations()
        }
    }

    // MARK: - Bezier Path

    func dkPathPath() -> UIBezierPath {
        let dkPathPath = UIBezierPath()
        dkPathPath.move(to: CGPoint(x: 48.913, y: 24.99))
        dkPathPath.addCurve(to: CGPoint(x: 38.952, y: 38.175), controlPoint1: CGPoint(x: 48.913, y: 24.99), controlPoint2: CGPoint(x: 39.693, y: 33.387))
        dkPathPath.addCurve(to: CGPoint(x: 67.006, y: 37.473), controlPoint1: CGPoint(x: 38.212, y: 42.963), controlPoint2: CGPoint(x: 76.622, y: 31.498))
        dkPathPath.addLine(to: CGPoint(x: 3.505, y: 62.604))
        dkPathPath.addCurve(to: CGPoint(x: 55.65, y: 52.815), controlPoint1: CGPoint(x: -14.561, y: 68.95), controlPoint2: CGPoint(x: 42.437, y: 53.27))
        dkPathPath.addCurve(to: CGPoint(x: 124.303, y: 50.053), controlPoint1: CGPoint(x: 74.137, y: 52.178), controlPoint2: CGPoint(x: 98.04, y: 50.957))
        dkPathPath.addCurve(to: CGPoint(x: 275.709, y: 50.979), controlPoint1: CGPoint(x: 185.369, y: 47.95), controlPoint2: CGPoint(x: 270.077, y: 51.117))
        dkPathPath.addCurve(to: CGPoint(x: 306.285, y: 48.617), controlPoint1: CGPoint(x: 279.134, y: 50.896), controlPoint2: CGPoint(x: 305.3, y: 50.581))
        dkPathPath.addCurve(to: CGPoint(x: 295.905, y: 45.875), controlPoint1: CGPoint(x: 307.27, y: 46.654), controlPoint2: CGPoint(x: 304.722, y: 47.193))
        dkPathPath.addCurve(to: CGPoint(x: 233.696, y: 39.7), controlPoint1: CGPoint(x: 286.263, y: 44.434), controlPoint2: CGPoint(x: 261.013, y: 40.822))
        dkPathPath.addCurve(to: CGPoint(x: 180.311, y: 38.801), controlPoint1: CGPoint(x: 215.095, y: 38.937), controlPoint2: CGPoint(x: 195.397, y: 39.37))
        dkPathPath.addCurve(to: CGPoint(x: 135.698, y: 40.93), controlPoint1: CGPoint(x: 165.84, y: 38.255), controlPoint2: CGPoint(x: 141.916, y: 39.94))
        dkPathPath.addCurve(to: CGPoint(x: 103.973, y: 46.234), controlPoint1: CGPoint(x: 129.479, y: 41.921), controlPoint2: CGPoint(x: 111.338, y: 45.09))
        dkPathPath.addCurve(to: CGPoint(x: 80.809, y: 49.832), controlPoint1: CGPoint(x: 98.182, y: 47.134), controlPoint2: CGPoint(x: 86.6, y: 48.933))
        dkPathPath.addCurve(to: CGPoint(x: 49.39, y: 84.986), controlPoint1: CGPoint(x: 81.504, y: 45.462), controlPoint2: CGPoint(x: 53.319, y: 82.643))
        dkPathPath.addCurve(to: CGPoint(x: 39.929, y: 86.16), controlPoint1: CGPoint(x: 49.39, y: 84.986), controlPoint2: CGPoint(x: 44.584, y: 90.51))
        dkPathPath.addCurve(to: CGPoint(x: 56.817, y: 55.878), controlPoint1: CGPoint(x: 39.929, y: 86.16), controlPoint2: CGPoint(x: 42.135, y: 64.133))
        dkPathPath.addCurve(to: CGPoint(x: 44.568, y: 91.697), controlPoint1: CGPoint(x: 71.499, y: 47.622), controlPoint2: CGPoint(x: 45.252, y: 87.865))
        dkPathPath.addCurve(to: CGPoint(x: 40.818, y: 119.036), controlPoint1: CGPoint(x: 43.126, y: 99.779), controlPoint2: CGPoint(x: 41.614, y: 116.253))
        dkPathPath.addCurve(to: CGPoint(x: 39.392, y: 130.763), controlPoint1: CGPoint(x: 40.022, y: 121.818), controlPoint2: CGPoint(x: 37.971, y: 142.579))
        dkPathPath.addCurve(to: CGPoint(x: 48.424, y: 75.21), controlPoint1: CGPoint(x: 42.123, y: 108.059), controlPoint2: CGPoint(x: 42.519, y: 103.901))
        dkPathPath.addCurve(to: CGPoint(x: 61.702, y: 5.748), controlPoint1: CGPoint(x: 54.942, y: 43.544), controlPoint2: CGPoint(x: 64.193, y: 9.591))
        dkPathPath.addCurve(to: CGPoint(x: 54.264, y: 5.592), controlPoint1: CGPoint(x: 56.953, y: -1.576), controlPoint2: CGPoint(x: 55.228, y: -2.194))
        dkPathPath.addCurve(to: CGPoint(x: 67.045, y: 40.047), controlPoint1: CGPoint(x: 53.301, y: 13.378), controlPoint2: CGPoint(x: 58.282, y: 34.777))
        dkPathPath.addCurve(to: CGPoint(x: 81.448, y: 52.416), controlPoint1: CGPoint(x: 75.808, y: 45.317), controlPoint2: CGPoint(x: 81.448, y: 52.416))
        dkPathPath.addCurve(to: CGPoint(x: 83.043, y: 84.806), controlPoint1: CGPoint(x: 81.448, y: 52.416), controlPoint2: CGPoint(x: 82.134, y: 84.895))
        dkPathPath.addCurve(to: CGPoint(x: 108.308, y: 27.251), controlPoint1: CGPoint(x: 83.043, y: 84.806), controlPoint2: CGPoint(x: 104.7, y: 26.545))
        dkPathPath.addCurve(to: CGPoint(x: 110.751, y: 87.048), controlPoint1: CGPoint(x: 111.917, y: 27.958), controlPoint2: CGPoint(x: 112.83, y: 71.973))
        dkPathPath.addCurve(to: CGPoint(x: 110.363, y: 54.132), controlPoint1: CGPoint(x: 108.672, y: 102.124), controlPoint2: CGPoint(x: 102.974, y: 54.556))
        dkPathPath.addCurve(to: CGPoint(x: 100.308, y: 87.805), controlPoint1: CGPoint(x: 117.752, y: 53.707), controlPoint2: CGPoint(x: 124.785, y: 56.365))
        dkPathPath.addLine(to: CGPoint(x: 99.375, y: 90.967))
        dkPathPath.addCurve(to: CGPoint(x: 124.012, y: 84.647), controlPoint1: CGPoint(x: 99.375, y: 90.967), controlPoint2: CGPoint(x: 124.829, y: 84.896))
        dkPathPath.addCurve(to: CGPoint(x: 138.068, y: 55.54), controlPoint1: CGPoint(x: 123.196, y: 84.398), controlPoint2: CGPoint(x: 135.413, y: 55.118))
        dkPathPath.addCurve(to: CGPoint(x: 148.55, y: 50.707), controlPoint1: CGPoint(x: 140.723, y: 55.962), controlPoint2: CGPoint(x: 148.55, y: 50.707))
        dkPathPath.addLine(to: CGPoint(x: 142.206, y: 45.336))
        dkPathPath.addCurve(to: CGPoint(x: 144.76, y: 70.854), controlPoint1: CGPoint(x: 142.206, y: 45.336), controlPoint2: CGPoint(x: 141.206, y: 71.764))
        dkPathPath.addCurve(to: CGPoint(x: 153.758, y: 48.542), controlPoint1: CGPoint(x: 144.76, y: 70.854), controlPoint2: CGPoint(x: 154.264, y: 54.63))
        dkPathPath.addCurve(to: CGPoint(x: 156.137, y: 62.723), controlPoint1: CGPoint(x: 153.252, y: 42.454), controlPoint2: CGPoint(x: 156.137, y: 62.723))
        dkPathPath.addCurve(to: CGPoint(x: 170.604, y: 44.768), controlPoint1: CGPoint(x: 156.137, y: 62.723), controlPoint2: CGPoint(x: 168.431, y: 44.923))
        dkPathPath.addCurve(to: CGPoint(x: 185.283, y: 44.075), controlPoint1: CGPoint(x: 172.777, y: 44.613), controlPoint2: CGPoint(x: 174.971, y: 41.004))
        dkPathPath.addCurve(to: CGPoint(x: 170.888, y: 68.751), controlPoint1: CGPoint(x: 195.594, y: 47.146), controlPoint2: CGPoint(x: 171.412, y: 67.882))
        dkPathPath.addCurve(to: CGPoint(x: 169.365, y: 23.825), controlPoint1: CGPoint(x: 170.364, y: 69.621), controlPoint2: CGPoint(x: 152.954, y: 73.699))
        dkPathPath.addCurve(to: CGPoint(x: 174.757, y: 32.41), controlPoint1: CGPoint(x: 172.456, y: 14.434), controlPoint2: CGPoint(x: 174.993, y: 26.345))
        dkPathPath.addCurve(to: CGPoint(x: 169.789, y: 103.827), controlPoint1: CGPoint(x: 174.52, y: 38.474), controlPoint2: CGPoint(x: 169.789, y: 103.827))

        return dkPathPath
    }

    class DKAHelp {
        class func reverseAnimation(anim: CAAnimation, totalDuration: CFTimeInterval) -> CAAnimation {
            var duration: CFTimeInterval = anim.duration + (anim.autoreverses ? anim.duration : 0)
            if anim.repeatCount > 1 {
                duration *= CFTimeInterval(anim.repeatCount)
            }
            let endTime = anim.beginTime + duration
            let reverseStartTime = totalDuration - endTime

            var newAnim: CAAnimation!

            // Reverse timing function closure
            let reverseTimingFunction = {
                (theAnim: CAAnimation) -> Void in
                let timingFunction = theAnim.timingFunction
                if timingFunction != nil {
                    var first: [Float] = [0, 0]
                    var second: [Float] = [0, 0]
                    timingFunction?.getControlPoint(at: 1, values: &first)
                    timingFunction?.getControlPoint(at: 2, values: &second)

                    theAnim.timingFunction = CAMediaTimingFunction(controlPoints: 1 - second[0], 1 - second[1], 1 - first[0], 1 - first[1])
                }
            }

            // Reverse animation values appropriately
            if let basicAnim = anim as? CABasicAnimation {
                if !anim.autoreverses {
                    let fromValue: Any! = basicAnim.toValue
                    basicAnim.toValue = basicAnim.fromValue
                    basicAnim.fromValue = fromValue
                    reverseTimingFunction(basicAnim)
                }
                basicAnim.beginTime = CFTimeInterval(reverseStartTime)

                if reverseStartTime > 0 {
                    let groupAnim = CAAnimationGroup()
                    groupAnim.animations = [basicAnim]
                    groupAnim.duration = maxDuration(ofAnimations: groupAnim.animations! as [CAAnimation])
                    for anim in groupAnim.animations! {
                        anim.fillMode = .both
                    }
                    newAnim = groupAnim
                } else {
                    newAnim = basicAnim
                }

            } else if let keyAnim = anim as? CAKeyframeAnimation {
                if !anim.autoreverses {
                    let values: [Any] = (keyAnim.values?.reversed())!
                    keyAnim.values = values
                    reverseTimingFunction(keyAnim)
                }
                keyAnim.beginTime = CFTimeInterval(reverseStartTime)

                if reverseStartTime > 0 {
                    let groupAnim = CAAnimationGroup()
                    groupAnim.animations = [keyAnim]
                    groupAnim.duration = maxDuration(ofAnimations: groupAnim.animations! as [CAAnimation])
                    for anim in groupAnim.animations! {
                        anim.fillMode = .both
                    }
                    newAnim = groupAnim
                } else {
                    newAnim = keyAnim
                }
            } else if let groupAnim = anim as? CAAnimationGroup {
                var newSubAnims: [CAAnimation] = []
                for subAnim in groupAnim.animations! as [CAAnimation] {
                    let newSubAnim = reverseAnimation(anim: subAnim, totalDuration: totalDuration)
                    newSubAnims.append(newSubAnim)
                }

                groupAnim.animations = newSubAnims
                for anim in groupAnim.animations! {
                    anim.fillMode = .both
                }
                groupAnim.duration = maxDuration(ofAnimations: newSubAnims)
                newAnim = groupAnim
            } else {
                newAnim = anim
            }
            return newAnim
        }

        class func group(animations: [CAAnimation], fillMode: CAMediaTimingFillMode!, forEffectLayer: Bool = false, sublayersCount: NSInteger = 0) -> CAAnimationGroup! {
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = animations

            if fillMode != nil {
                if let animations = groupAnimation.animations {
                    for anim in animations {
                        anim.fillMode = fillMode
                    }
                }
                groupAnimation.fillMode = fillMode
                groupAnimation.isRemovedOnCompletion = false
            }

            if forEffectLayer {
                groupAnimation.duration = DKAHelp.maxDuration(ofEffectAnimation: groupAnimation, sublayersCount: sublayersCount)
            } else {
                groupAnimation.duration = DKAHelp.maxDuration(ofAnimations: animations)
            }

            return groupAnimation
        }

        class func maxDuration(ofAnimations anims: [CAAnimation]) -> CFTimeInterval {
            var maxDuration: CGFloat = 0
            for anim in anims {
                maxDuration = max(CGFloat(anim.beginTime + anim.duration) * CGFloat(anim.repeatCount == 0 ? 1.0 : anim.repeatCount) * (anim.autoreverses ? 2.0 : 1.0), maxDuration)
            }

            if maxDuration.isInfinite {
                return TimeInterval(NSIntegerMax)
            }

            return CFTimeInterval(maxDuration)
        }

        class func maxDuration(ofEffectAnimation anim: CAAnimation, sublayersCount: NSInteger) -> CFTimeInterval {
            var maxDuration: CGFloat = 0
            if let groupAnim = anim as? CAAnimationGroup {
                for subAnim in groupAnim.animations! as [CAAnimation] {
                    var delay: CGFloat = 0
                    if let instDelay = (subAnim.value(forKey: "instanceDelay") as? NSNumber)?.floatValue {
                        delay = CGFloat(instDelay) * CGFloat(sublayersCount - 1)
                    }
                    var repeatCountDuration: CGFloat = 0
                    if subAnim.repeatCount > 1 {
                        repeatCountDuration = CGFloat(subAnim.duration) * CGFloat(subAnim.repeatCount - 1)
                    }
                    var duration: CGFloat = 0

                    duration = CGFloat(subAnim.beginTime) + (subAnim.autoreverses ? CGFloat(subAnim.duration) : CGFloat(0)) + delay + CGFloat(subAnim.duration) + CGFloat(repeatCountDuration)
                    maxDuration = max(duration, maxDuration)
                }
            }

            if maxDuration.isInfinite {
                maxDuration = 1000
            }

            return CFTimeInterval(maxDuration)
        }

        class func updateValueFromAnimations(forLayers layers: [CALayer]) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            for aLayer in layers {
                if let keys = aLayer.animationKeys() as [String]! {
                    for animKey in keys {
                        let anim = aLayer.animation(forKey: animKey)
                        updateValue(forAnimation: anim!, theLayer: aLayer)
                    }
                }
            }

            CATransaction.commit()
        }

        class func updateValue(forAnimation anim: CAAnimation, theLayer: CALayer) {
            if let basicAnim = anim as? CABasicAnimation {
                if !basicAnim.autoreverses {
                    theLayer.setValue(basicAnim.toValue, forKeyPath: basicAnim.keyPath!)
                }
            } else if let keyAnim = anim as? CAKeyframeAnimation {
                if !keyAnim.autoreverses {
                    theLayer.setValue(keyAnim.values?.last, forKeyPath: keyAnim.keyPath!)
                }
            } else if let groupAnim = anim as? CAAnimationGroup {
                for subAnim in groupAnim.animations! as [CAAnimation] {
                    updateValue(forAnimation: subAnim, theLayer: theLayer)
                }
            }
        }

        class func updateValueFromPresentationLayer(forAnimation anim: CAAnimation!, theLayer: CALayer) {
            if let basicAnim = anim as? CABasicAnimation {
                theLayer.setValue(theLayer.presentation()?.value(forKeyPath: basicAnim.keyPath!), forKeyPath: basicAnim.keyPath!)
            } else if let keyAnim = anim as? CAKeyframeAnimation {
                theLayer.setValue(theLayer.presentation()?.value(forKeyPath: keyAnim.keyPath!), forKeyPath: keyAnim.keyPath!)
            } else if let groupAnim = anim as? CAAnimationGroup {
                for subAnim in groupAnim.animations! as [CAAnimation] {
                    updateValueFromPresentationLayer(forAnimation: subAnim, theLayer: theLayer)
                }
            }
        }

        class func addSublayersAnimation(anim: CAAnimation, key: String, layer: CALayer) {
            return addSublayersAnimationNeedReverse(anim: anim, key: key, layer: layer, reverseAnimation: false, totalDuration: 0)
        }

        class func addSublayersAnimationNeedReverse(anim: CAAnimation, key: String, layer: CALayer, reverseAnimation: Bool, totalDuration: CFTimeInterval) {
            let sublayers = layer.sublayers
            let sublayersCount = sublayers!.count

            let setBeginTime = {
                (subAnim: CAAnimation, sublayerIdx: NSInteger) -> Void in

                if let instDelay = (subAnim.value(forKey: "instanceDelay") as? NSNumber)?.floatValue {
                    if instDelay != 0 {
                        let instanceDelay = CGFloat(instDelay)
                        let orderType: NSInteger = ((subAnim.value(forKey: "instanceOrder")!) as AnyObject).integerValue
                        switch orderType {
                        case 0: subAnim.beginTime = CFTimeInterval(CGFloat(subAnim.beginTime) + CGFloat(sublayerIdx) * instanceDelay)
                        case 1: subAnim.beginTime = CFTimeInterval(CGFloat(subAnim.beginTime) + CGFloat(sublayersCount - sublayerIdx - 1) * instanceDelay)
                        case 2:
                            let middleIdx = sublayersCount / 2
                            let begin = CGFloat(abs(middleIdx - sublayerIdx)) * instanceDelay
                            subAnim.beginTime += CFTimeInterval(begin)

                        case 3:
                            let middleIdx = sublayersCount / 2
                            let begin = CGFloat(middleIdx - abs((middleIdx - sublayerIdx))) * instanceDelay
                            subAnim.beginTime += CFTimeInterval(begin)

                        default:
                            break
                        }
                    }
                }
            }

            for (idx, sublayer) in sublayers!.enumerated() {
                if let groupAnim = anim.copy() as? CAAnimationGroup {
                    var newSubAnimations: [CAAnimation] = []
                    for subAnim in groupAnim.animations! {
                        newSubAnimations.append(subAnim.copy() as! CAAnimation)
                    }
                    groupAnim.animations = newSubAnimations
                    let animations = groupAnim.animations
                    for sub in animations! as [CAAnimation] {
                        setBeginTime(sub, idx)
                        // Reverse animation if needed
                        if reverseAnimation {
                            _ = self.reverseAnimation(anim: sub, totalDuration: totalDuration)
                        }
                    }
                    sublayer.add(groupAnim, forKey: key)
                } else {
                    let copiedAnim = anim.copy() as! CAAnimation
                    setBeginTime(copiedAnim, idx)
                    sublayer.add(copiedAnim, forKey: key)
                }
            }
        }

        class func alignToBottomPath(path: UIBezierPath, layer: CALayer) -> UIBezierPath {
            let diff = layer.bounds.maxY - path.bounds.maxY
            let transform = CGAffineTransform.identity.translatedBy(x: 0, y: diff)
            path.apply(transform)
            return path
        }

        class func offsetPath(path: UIBezierPath, offset: CGPoint) -> UIBezierPath {
            let affineTransform = CGAffineTransform.identity.translatedBy(x: offset.x, y: offset.y)
            path.apply(affineTransform)
            return path
        }
    }
}
