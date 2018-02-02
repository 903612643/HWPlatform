import UIKit

class NineCellLockView: UIView //,PSetSelectedValue
{
    var fingerPoint:CGPoint = CGPoint()
    var linePointointCollection:Array<CGPoint> = Array<CGPoint>()
    var ninePointCollection:Array<CGPoint> = Array<CGPoint>()
    
    var selectPointIndexCollection:Array<Int> = Array<Int>()
    var parentViewController:PSetSelectedValue!
    
    var circleRadius:CGFloat = 28
    var circleCenterDistance:CGFloat = 96
    private var firstCirclePointX:CGFloat = 96
    private var firstCirclePointY:CGFloat = 30
    var isDrawLine = true
    private var innerCircleRadius:CGFloat = 10
 
    var easyUsing = false
    
    var minEdge:CGFloat{
        return circleRadius * 2 + circleCenterDistance * 2
    }
    
    func FillNinePointCollection()
    {
        self.ninePointCollection.removeAll(keepCapacity: false)
        for row in 0...2
        {
            for column in 0...2
            {
                let tempX:CGFloat = CGFloat(column) * self.circleCenterDistance + self.firstCirclePointX
                let tempY:CGFloat = CGFloat(row) * self.circleCenterDistance + self.firstCirclePointY
                self.ninePointCollection.append(CGPoint(x: tempX,y:tempY))
            }
        }
    }
    
    func RefreshView(radius:CGFloat,centerDistance:CGFloat){
        easyUsing = true
        innerCircleRadius = 5
        isDrawLine = false
        circleCenterDistance = centerDistance
        circleRadius = radius

        firstCirclePointX = (frame.width - minEdge)/2 + circleRadius
        firstCirclePointY = (frame.height - minEdge)/2 + circleRadius
        
        FillNinePointCollection()
        self.setNeedsDisplay()
    }
    
    func drawCicle(centerPoint:CGPoint,index:Int)
    {
        let context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2.0);
        CGContextAddArc(context, centerPoint.x, centerPoint.y, self.circleRadius, 0.0, CGFloat(M_PI * 2.0), 1)
        let currentIsSelected:Bool = self.selectPointIndexCollection.contains(index)
        if(currentIsSelected)
        {
            //96 169 252
            CGContextSetStrokeColorWithColor(context, UIColor(red: 96/255.0, green: 169/255.0, blue: 252/255.0, alpha: 1).CGColor)
        }
        else
        {
            CGContextSetStrokeColorWithColor(context,  UIColor(red: 144/255.0, green: 149/255.0, blue: 173/255.0, alpha: 1).CGColor)
        }
        
        CGContextStrokePath(context);
        CGContextAddArc(context, centerPoint.x, centerPoint.y, self.circleRadius, 0.0, CGFloat(M_PI * 2.0), 1)
        CGContextSetFillColorWithColor(context,  UIColor(red: 35/255.0, green: 39/255.0, blue: 54/255.0, alpha: 0).CGColor)
        CGContextFillPath(context)
        
        if(currentIsSelected)
        {
            CGContextAddArc(context, centerPoint.x, centerPoint.y, innerCircleRadius, 0.0, CGFloat(M_PI * 2.0), 1)
            CGContextSetFillColorWithColor(context, UIColor(red: 96/255.0, green: 169/255.0, blue: 252/255.0, alpha: 1).CGColor)
            CGContextFillPath(context)
        }
    }
    
    func drawNineCircle()
    {
        for p in 0...self.ninePointCollection.count-1
        {
            self.drawCicle(self.ninePointCollection[p],index:p);
        }
    }
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        //26 29 40
        self.backgroundColor = UIColor(red: 35/255.0, green: 39/255.0, blue: 54/255.0, alpha: 1)
        //self.backgroundColor = UIColor.redColor()
        
        firstCirclePointX = (frame.width - minEdge)/2 + circleRadius
        firstCirclePointY = firstCirclePointX + circleRadius
        
        FillNinePointCollection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func DrawLine(p1:CGPoint,p2:CGPoint)
    {
        let bp = UIBezierPath()
        bp.lineWidth  = 3
        bp.lineCapStyle = CGLineCap.Round
        UIColor(red: 96/255.0, green: 169/255.0, blue: 252/255.0, alpha: 1).setStroke()
        bp.moveToPoint(p1)
        bp.addLineToPoint(p2)
        bp.stroke()
        
    }
    
    func DrawLine(p1:CGPoint,p2:CGPoint,color:UIColor)
    {
        let bp = UIBezierPath()
        bp.lineWidth  = 3
        bp.lineCapStyle = CGLineCap.Round
        color.setStroke()
        bp.moveToPoint(p1)
        bp.addLineToPoint(p2)
        bp.stroke()
        
    }
    
    override func drawRect(rect: CGRect) {
        
        if isDrawLine{
        let var1 = CGPoint(x: 0, y: 0)
        let var2 = CGPoint(x: self.frame.size.width, y: 0)
        DrawLine(var1, p2: var2,color:UIColor.grayColor())
        }
        
        if(self.selectPointIndexCollection.count > 0)
        {
            for index in 0...self.selectPointIndexCollection.count-1
            {
                let nextIndex = index+1
                if(nextIndex <= self.selectPointIndexCollection.count-1)
                {
                    let firstPointIndex=self.selectPointIndexCollection[index]
                    let secondPointIndex=self.selectPointIndexCollection[nextIndex]
                    self.DrawLine(self.ninePointCollection[firstPointIndex],p2:self.ninePointCollection[secondPointIndex])
                }
            }
            if self.fingerPoint.x != -100 && easyUsing == false
            {
                let lastPointIndex=self.selectPointIndexCollection[self.selectPointIndexCollection.count-1]
                self.DrawLine(self.ninePointCollection[lastPointIndex],p2:fingerPoint)
            }
        }
        self.drawNineCircle()
    }
    
    func distanceBetweenTwoPoint(p1:CGPoint,p2:CGPoint)->CGFloat
    {
        return pow(pow((p1.x-p2.x), 2)+pow((p1.y-p2.y), 2), 0.5)
    }
    
    func CircleIsTouchThenPushInSelectPointIndexCollection(fingerPoint:CGPoint)
    {
        for index in 0...self.ninePointCollection.count-1
        {
            if(!self.selectPointIndexCollection.contains(index))
            {
                if(self.distanceBetweenTwoPoint(fingerPoint,p2:self.ninePointCollection[index]) <= circleRadius)
                {
                    self.selectPointIndexCollection.append(index);
                    self.parentViewController .addElement(index)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if easyUsing{
            return
        }
        
        let t = touches.first!
        self.selectPointIndexCollection.removeAll(keepCapacity: false)
        self.fingerPoint = t.locationInView(self)
        self.CircleIsTouchThenPushInSelectPointIndexCollection(fingerPoint);
        self.setNeedsDisplay()
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if easyUsing{
            return
        }
        
        let t = touches.first!
        //var t = touches.anyObject() as! UITouch
        self.fingerPoint = t.locationInView(self)
        self.CircleIsTouchThenPushInSelectPointIndexCollection(self.fingerPoint);
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if easyUsing{
            return
        }
        
        self.fingerPoint.x = -100
        self.setNeedsDisplay()
        if(self.selectPointIndexCollection.count>0)
        {
            parentViewController.overGestrue()
        }
    }
    
    func PrintPWD()->String{
        var ReStr:String = ""
        for index in 0...self.selectPointIndexCollection.count-1
        {
            ReStr += String(self.selectPointIndexCollection[index]) + ","
        }
        return ReStr
    }
}