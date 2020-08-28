//
//  ViewController.swift
//  LocationTest
//
//  Created by Ludovico Veniani on 8/12/20.
//  Copyright © 2020 Ludovico Verniani. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setup()
        
    }
    
    var label: UILabel = {
        let lbl = UILabel()
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints  = true
        lbl.textColor = .white
        lbl.font = .boldSystemFont(ofSize: 100)
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var btn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Refresh", for: .normal)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        btn.clipsToBounds = true
        btn.layer.masksToBounds = true
        return btn
    }()
    
    
    
    func setup() {
        view.addSubview(label)
        
        
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: view.frame.width, height: view.frame.height)
        label.text = String(UserDefaults.standard.integer(forKey: Location.counter))
        
        
        if Location.locationManager == nil {
            Location.initializeManager()
        }
        Location.VC = self
        
    }
    
    @objc func refresh() {
        label.text = String(UserDefaults.standard.integer(forKey: Location.counter))
    }
    
    
}










extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}
