//
//  ViewController.swift
//  panGestureDragTest
//
//  Created by Vic W. on 12/20/18.
//  Copyright © 2018 Vic Winkler. All rights reserved.
//
// This is a demonstration of panGestureRecognizer to "drag" a UIView.
// When the user touches a source color swatch (at the bottom) and starts
// the panGesture, the "dragView" becomes visible and is set to the source
// color. Once the dragView is within a "destination view", the destination
// is set to the dragView color. Then:
//   --If the user ends the drag within that destination, the color stays set.
//   --If the user moves the dragView back out of the destination, the
//     destination is "reset" to it's previous color.

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var redValue:   UILabel!     // RGB "source" values
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue:  UILabel!
   
    @IBOutlet      var theView:  UIView!        // UIView background
    // Note: Do *not* set IB constraints on dragView, set them in code
    @IBOutlet weak var dragView: UIView!        // the view that gets dragged
    
    @IBOutlet weak var source1:  UIView!        // color "sources" for drag
    @IBOutlet weak var source2:  UIView!
    @IBOutlet weak var source3:  UIView!
    
    @IBOutlet weak var target1: UIView!         // We drag to a "destination"
    @IBOutlet weak var target2: UIView!         // which receives the source
    @IBOutlet weak var target3: UIView!         // color
    
    @IBOutlet weak var xyCoordinates: UILabel!
    @IBOutlet weak var startStatus:   UILabel!
    @IBOutlet weak var dragStatus:    UILabel!
    var dragTargets:[UIView?: UIColor?] = [:]
    
    var dragColor = UIColor()
    
    var red:   CGFloat = 0 // rgba get set by UIColor.getRed()
    var green: CGFloat = 0
    var blue:  CGFloat = 0
    var alpha: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize feedback text, dragView and target dictionaries...
        startStatus.text = ""
        dragStatus.text  = ""

        dragView.backgroundColor = UIColor.purple
        dragView.alpha = 0
        dragView.frame.size.width   = 80
        dragView.frame.size.height  = 80
        dragView.layer.cornerRadius = dragView.frame.size.width / 2
        dragView.layer.borderColor  = UIColor.black.cgColor
        dragView.layer.borderWidth  = 0.5

        dragTargets = [self.target1: target1.backgroundColor,
                       self.target2: target2.backgroundColor,
                       self.target3: target3.backgroundColor]
    }
    
    @IBAction func userIsPanning(_ sender: UIPanGestureRecognizer) {
        // Determine in which source swatch user started panGesture...
        guard let swatch = sender.view else { return }
       
        let senderXY = sender.location(in: theView) // xy in the screen "theView"
        let senderX  = senderXY.x
        let senderY  = senderXY.y
        // convert from CGPoint and display the dragging coordinates
        let coordinates = String(Int(senderX)) + ", " + String(Int(senderY))
        xyCoordinates.text = coordinates

        // Depending on pan state, we begin, continue or end the drag
        switch sender.state {
        case .cancelled:
            dragStatus.text = "drag cancelled"
            dragView.alpha  = 0
            
        case .began:
            startStatus.text = "drag began"
            dragView.alpha   = 1
            // When drag begins, we load dictionary with original
            // target colors because we may need to reset target on ".ended"
            dragTargets = [self.target1: target1.backgroundColor,
                           self.target2: target2.backgroundColor,
                           self.target3: target3.backgroundColor]
            dragColor = swatch.backgroundColor ?? UIColor.purple
            dragView.backgroundColor = dragColor
            dragColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let r = String(Int(red   * 255))
            let g = String(Int(green * 255))
            let b = String(Int(blue  * 255))
            redValue.text=r; greenValue.text=g; blueValue.text=b
            
            dragView.center = self.view.convert(sender.location(in: swatch),
                                                from: swatch)
            fallthrough
            
        case .changed:
            dragStatus.text = "drag continues..."
            let translation = sender.translation(in: self.view)
            dragView.transform = CGAffineTransform(translationX: translation.x,
                                                   y:            translation.y)
            
            let newCenter = CGPoint(x: dragView.center.x + translation.x,
                                    y: dragView.center.y + translation.y)
            // Set a target to the drag color if dragView is within the target
            for (target, preDragColor) in dragTargets {
                let targetFrame = self.view.convert(target!.bounds,
                                                    from: target)
                if targetFrame.contains(newCenter) {
                    target?.backgroundColor = dragColor
                } else {
                    target?.backgroundColor = preDragColor
                }
            }

        case .ended:
            startStatus.text = ""
            dragStatus.text      = "drag ended"
            dragView.alpha   = 0
            // Pan ended, but did it end inside bounds of a target?
            let translation  = sender.translation(in: self.view)
            let newCenter    = CGPoint(x: dragView.center.x + translation.x,
                                       y: dragView.center.y + translation.y)
            for (target, preDragColor) in dragTargets {
                let targetFrame = self.view.convert(target!.bounds, from: target)
                // If pan did not end inside a target, reset the target color
                if !targetFrame.contains(newCenter) {
                    target?.backgroundColor = preDragColor
                }
            }

        default:  break
        }
    }
}
