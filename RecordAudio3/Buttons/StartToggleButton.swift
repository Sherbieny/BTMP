//
//  StartToggleButton.swift
//  RecordAudio3
//
//  Created by Eslam El Sherbieny on 11.02.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//

import UIKit

@IBDesignable extension UIButton {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

class StartToggleButton: UIButton {
    var isOn = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }

    func initButton() {
        layer.cornerRadius = frame.size.width / 2.0
        layer.backgroundColor = UIColor.black.cgColor
        layer.borderColor = UIColor.white.cgColor
        setTitleColor(UIColor.white, for: .normal)
        addTarget(self, action: #selector(StartToggleButton.buttonPressed),for: . touchUpInside)
        
    }

    @objc func buttonPressed() {
        activateButton(state: !isOn)
    }

    func activateButton(state: Bool) {
        isOn = state
        
        let color = state ? UIColor.white : UIColor.black
        let title = state ? "Stop" : "Start"
        let titleColor = state ? UIColor.black : UIColor.white
        let borderColor = state ? UIColor.black : UIColor.white
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
        layer.borderColor = borderColor.cgColor
    }
}
