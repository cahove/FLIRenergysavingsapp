//
//  GradientView.swift
//  FLIROneCameraSwift
//
//  Created by Christopher Hove on 17/09/2022.
//  Copyright © 2022 sample. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var FirstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var SecondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }

    override class var layerClass: AnyClass {
        get{
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        
        layer.colors = [FirstColor.cgColor, SecondColor.cgColor]
    }

}
