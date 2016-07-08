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
    
    public var drawArea:Bool = false
    public var fillArea:Bool = false
    
    public var lineColor:UIColor = UIColor.blackColor()
    public var fillColor:UIColor = UIColor.grayColor()
    
    private var values:[CGFloat] = []
    private var points:[Point] = []
    
    private var dataMinimum:CGFloat = 0.0
    private var dataMaximum:CGFloat = 0.0
    
    private var xInc:CGFloat = 0.0
    private var yInc:CGFloat = 0.0
    
    private var graphMax:CGFloat = 0.0
    private var graphMin:CGFloat = 0.0
    
    private var fullWidth:CGFloat {
        return CGRectGetWidth(self.bounds)
    }
    
    private var fullHeight:CGFloat {
        return CGRectGetHeight(self.bounds)
    }
    
    private let MARKER_MIN_SIZE:CGFloat = 2.0
    private let DEF_MARKER_SIZE_FRAC:CGFloat = 0.2
    private let MARKER_MAX_SIZE:CGFloat = 4.0
    
    private var markerSize:CGFloat {
        var size = self.fullHeight * DEF_MARKER_SIZE_FRAC
        
        if size < MARKER_MIN_SIZE {
            size = MARKER_MIN_SIZE
        } else if size > MARKER_MAX_SIZE {
            size = MARKER_MAX_SIZE
        }
        return size
    }
    
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
        self.createDataStatistics()
        
        let label = UILabel(frame: CGRectMake(0,0,CGRectGetWidth(self.frame),20))
        label.text = "width: \(CGRectGetWidth(self.frame)) - height: \(CGRectGetHeight(self.frame))"
        self.addSubview(label)
        
        let graphSize:CGFloat = CGRectGetWidth(self.bounds) * 0.95
        let graphFrac:CGFloat = graphSize / CGRectGetWidth(self.bounds)
        
        let dataMin:CGFloat = self.dataMinimum
        let dataMax:CGFloat = self.dataMaximum
        
        let sparkWidth = self.fullWidth
        let sparkHeight = self.fullHeight - (2 * GRAPH_Y_BORDER)
        
        self.graphMax = dataMax
        self.graphMin = dataMin
        
        if graphMin == graphMax {
            graphMin *= 1.0 - CONSTANT_GRAPH_BUFFER
            graphMax *= 1.0 + CONSTANT_GRAPH_BUFFER
        }
        
        let counter = self.values.count
        self.xInc = (sparkWidth / CGFloat(counter-1)) - self.markerSize
        if counter <= 2 {
            self.xInc = self.xInc - self.markerSize - GRAPH_X_BORDER
        }
        
        self.yInc = ((sparkHeight - 5.0) / (graphMax - graphMin))
        
        let ctx = UIGraphicsGetCurrentContext()
        self.drawLinesInContext(ctx!)
        self.drawPointMarkerInContext(ctx!)
        
    }
    
    public func show(values:[CGFloat]) {
        self.values = values
        self.setNeedsLayout()
        self.setNeedsDisplay()
        self.layoutIfNeeded()
    }
    
    private func createDataStatistics() {
        
        let numData = self.values.count
        
        if numData == 1 {
            
            self.dataMinimum = self.values.last!
            self.dataMaximum = self.values.last!
            self.values.append(self.values.last!)
            
        } else if numData > 1 {
            
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
        self.clearsContextBeforeDrawing = true
        self.backgroundColor = UIColor.clearColor()
    }
    
    private func drawLinesInContext(context:CGContextRef) {
        
        CGContextSetLineWidth(context, 1.0 / self.contentScaleFactor)
        
        self.lineColor.setStroke()
        
        CGContextBeginPath(context)
        
        for (index, value) in self.values.enumerate() {
            
            let xPos = ((self.xInc * CGFloat(index)) + GRAPH_X_BORDER) + self.markerSize
            
            let yPos = yPlotValue(self.fullHeight, yInc: self.yInc, val: value, offset: self.graphMin, penWidth: 5.0)
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
