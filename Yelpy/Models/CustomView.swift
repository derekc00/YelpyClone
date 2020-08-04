//
//  CustomView.swift
//  Yelpy
//
//  Created by Derek Chang on 8/1/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class CustomView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 0.5
            }, completion: nil)
        }
        
       
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endTap"), object: nil)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
}
