//
//  AnimatedViewPortJob.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class AnimatedViewPortJob: ViewPortJob
{
    open var phase: CGFloat = 1.0
    open var xOrigin: CGFloat = 0.0
    open var yOrigin: CGFloat = 0.0
    
    open var _startTime: TimeInterval = 0.0
    open var _displayLink: NSUIDisplayLink!
    open var _duration: TimeInterval = 0.0
    open var _endTime: TimeInterval = 0.0
    
    open var _easing: ChartEasingFunctionBlock?
    
    @objc public init(
        viewPortHandler: ViewPortHandler,
        xValue: Double,
        yValue: Double,
        transformer: Transformer,
        view: ChartViewBase,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        duration: TimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        super.init(viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: yValue,
            transformer: transformer,
            view: view)
        
        self.xOrigin = xOrigin
        self.yOrigin = yOrigin
        self._duration = duration
        self._easing = easing
    }
    
    deinit
    {
        stop(finish: false)
    }
    
    open override func doJob()
    {
        start()
    }
    
    @objc open func start()
    {
        _startTime = CACurrentMediaTime()
        _endTime = _startTime + _duration
        _endTime = _endTime > _endTime ? _endTime : _endTime
        
        updateAnimationPhase(_startTime)
        
        _displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
        _displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }
    
    @objc open func stop(finish: Bool)
    {
        guard _displayLink != nil else { return }

        _displayLink.remove(from: .main, forMode: RunLoop.Mode.common)
        _displayLink = nil

        if finish
        {
            if phase != 1.0
            {
                phase = 1.0
                animationUpdate()
            }

            animationEnd()
        }
    }
    
    open func updateAnimationPhase(_ currentTime: TimeInterval)
    {
        let elapsedTime = currentTime - _startTime
        let duration = _duration
        var elapsed = elapsedTime

        elapsed = min(elapsed, duration)

        phase = CGFloat(_easing?(elapsed, duration) ?? elapsed / duration)
    }
    
    @objc open func animationLoop()
    {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhase(currentTime)
        
        animationUpdate()
        
        if currentTime >= _endTime
        {
            stop(finish: true)
        }
    }
    
    open func animationUpdate()
    {
       // Override this
    }
    
    open func animationEnd()
    {
        // Override this
    }
}
