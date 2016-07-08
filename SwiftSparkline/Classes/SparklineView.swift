//
//  SparklineView.swift
//  Pods
//
//  Created by Ronaldo GomesJr on 22/04/2016.
//
//

import UIKit


struct Point {
    var x:CGFloat
    var y:CGFloat
}


public class SparklineView: UIView {

    private var values:[CGFloat] = []
    private var points:[Point] = []
    
    private var dataMinimum:CGFloat?
    private var dataMaximum:CGFloat?
    
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
    
    let GRAPH_X_BORDER:CGFloat = 2.0
    let GRAPH_Y_BORDER:CGFloat = 2.0
    let CONSTANT_GRAPH_BUFFER:CGFloat = 0.1
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
//
//        CGContextSetRGBFillColor(ctx, 110.0/255.0, 70.0/255.0, 150.0/255.0, 1.0)
//        CGContextSetLineWidth(ctx, 1.0)
//        CGContextSetLineCap(ctx, .Round)
//        CGContextSetLineJoin(ctx, .Round)
//        CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor)
//        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor)
//        
//        CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height)
//        CGContextScaleCTM(ctx, 1.0, -1.0)
//        
//        if self.drawArea {
//            self.drawAreaInRect(self.bounds, withContext: ctx!)
//        }
        
        self.drawLinesInContext(ctx!)
        
        self.drawPointMarkerInContext(ctx!)
        
    }
    
    private var xInc:CGFloat = 0.0
    private var yInc:CGFloat = 0.0
    
    private var graphMax:CGFloat = 0.0
    private var graphMin:CGFloat = 0.0
    
    private var fullWidth:CGFloat {
        return CGRectGetWidth(self.bounds)
    }
    
    private var fullheight:CGFloat {
        return CGRectGetHeight(self.bounds)
    }
    
    private let MARKER_MIN_SIZE:CGFloat = 2.0
    private let DEF_MARKER_SIZE_FRAC:CGFloat = 0.2
    private let MARKER_MAX_SIZE:CGFloat = 4.0
    
    private var markerSize:CGFloat {
        var size = self.fullheight * DEF_MARKER_SIZE_FRAC
        
        if size < MARKER_MIN_SIZE {
            size = MARKER_MIN_SIZE
        } else if size > MARKER_MAX_SIZE {
            size = MARKER_MAX_SIZE
        }
        return size
    }
    
    public func show(values:[CGFloat]) {
        self.values = values
        self.createDataStatistics()
        
        let graphSize:CGFloat = CGRectGetWidth(self.bounds) * 0.95
        let graphFrac:CGFloat = graphSize / CGRectGetWidth(self.bounds)
        
        let dataMin:CGFloat = self.dataMinimum!
        let dataMax:CGFloat = self.dataMaximum!
        
        let sparkWidth = self.fullWidth
        let sparkHeight = self.fullheight - (2 * GRAPH_Y_BORDER)
        
        self.graphMax = dataMax
        self.graphMin = dataMin
        
        if graphMin == graphMax {
            graphMin *= 1.0 - CONSTANT_GRAPH_BUFFER
            graphMax *= 1.0 + CONSTANT_GRAPH_BUFFER
        }
        
        self.xInc = (sparkWidth / (CGFloat(self.values.count) - 1)) - self.markerSize
        self.yInc = ((sparkHeight - 0.0) / (graphMax - graphMin))
        
        self.setNeedsDisplay()
    }
    
    private func createDataStatistics() {
        
        let numData = self.values.count
        
        if numData == 0 {
            
            self.dataMinimum = nil
            self.dataMaximum = nil
            
        } else if numData == 1 {
            
            self.dataMinimum = self.values.last!
            self.dataMaximum = self.values.last!
            
        } else {
            
            var _min = self.values.last!
            var _max = _min
            
            for val in self.values {
                
                _min = min(_min, val)
                _max = max(_max, val)
                
            }
            
            self.dataMinimum = _min
            self.dataMaximum = _max
        }
        
    }
    
    private func setupDefaults() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    private func drawLinesInContext(context:CGContextRef) {
        
        CGContextSetLineWidth(context, 1.0 / self.contentScaleFactor)
        
        self.lineColor.setStroke()
        
        CGContextBeginPath(context)
        
        for (index, value) in self.values.enumerate() {
            
            
            
            let xPos = ((self.xInc * CGFloat(index)) + GRAPH_X_BORDER) + self.markerSize
            
            
            var yPos = yPlotValue(self.fullheight, yInc: self.yInc, val: value, offset: self.graphMin, penWidth: 0)
            let point = Point(x: xPos, y: yPos)
            
            self.points.append(point)
            
            if index > 0 {
                CGContextAddLineToPoint(context, point.x, point.y)
            } else {
                CGContextMoveToPoint(context, point.x, point.y)
            }
            
        }
        
        CGContextStrokePath(context)
        
    }
    
    private func drawPointMarkerInContext(context:CGContext) {
        for point in self.points {
            let markRect = CGRectMake(point.x - (self.markerSize/2.0), point.y - (self.markerSize/2.0), self.markerSize, self.markerSize)
            self.lineColor.setFill()
            CGContextFillEllipseInRect(context, markRect)
        }
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
    
    private func yPlotValue(maxHeight:CGFloat, yInc:CGFloat, val:CGFloat, offset:CGFloat, penWidth:CGFloat) -> CGFloat {
        return maxHeight - ((yInc * (val - offset)) + GRAPH_Y_BORDER + (penWidth / 2.0))
    }

}
