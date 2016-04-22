//
//  SparklineView.swift
//  Pods
//
//  Created by Ronaldo GomesJr on 22/04/2016.
//
//

import UIKit

public class SparklineView: UIView {

    private var values:[Float] = []
    
    public var drawArea:Bool = false
    public var fillArea:Bool = false
    
    public var lineColor:UIColor = UIColor.blackColor()
    public var fillColor:UIColor = UIColor.grayColor()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupDefaults()
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetRGBFillColor(ctx, 110.0/255.0, 70.0/255.0, 150.0/255.0, 1.0)
        CGContextSetLineWidth(ctx, 1.0)
        CGContextSetLineCap(ctx, .Round)
        CGContextSetLineJoin(ctx, .Round)
        CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor)
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor)
        
        CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height)
        CGContextScaleCTM(ctx, 1.0, -1.0)
        
        if self.drawArea {
            self.drawAreaInRect(self.bounds, withContext: ctx!)
        }
        
        self.drawLinesInContext(ctx!)
        
    }
    
    public func show(values:[Float]) {
        self.values = values
        self.setNeedsDisplay()
    }
    
    private func setupDefaults() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    private func drawLinesInContext(context:CGContextRef) {
        let startY = self.bounds.size.height / 4
        let limitHeight = self.bounds.size.height - 10
        let distanceBetweenPoints = self.bounds.size.width / CGFloat(self.values.count)
        
        //MARK: Drawing with Path
        CGContextBeginPath(context)
        let mutablePath = CGPathCreateMutable()
        CGPathMoveToPoint(mutablePath, nil, 0, 0)
        CGPathAddLineToPoint(mutablePath, nil, 0, startY)
        
        for (index, value) in self.values.enumerate() {
            CGPathAddLineToPoint(mutablePath, nil, distanceBetweenPoints*CGFloat(index+1), min(limitHeight, CGFloat(startY+CGFloat(value))))
        }
        
        CGPathAddLineToPoint(mutablePath, nil, self.bounds.size.width, 0)
        
        CGPathCloseSubpath(mutablePath)
        
        CGContextAddPath(context, mutablePath)
        
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
    }
    
    private func drawingMode() -> CGPathDrawingMode {
        if self.fillArea {
            return .FillStroke
        } else {
            return .Stroke
        }
    }
    
    private func drawAreaInRect(rect:CGRect, withContext context:CGContextRef) {
        CGContextSaveGState(context)
        CGContextBeginPath(context)
        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddRect(path, nil, rect)
        CGContextAddPath(context, path)
        
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        CGContextRestoreGState(context)
    }

}
