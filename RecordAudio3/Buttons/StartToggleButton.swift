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
        addTarget(self, action: #selector(StartToggleButton.buttonPressed), for: .touchUpInside)
    }

    func deactivateButton() {
        let color = UIColor.black
        let title = "Start"
        let titleColor = UIColor.white
        let borderColor = UIColor.white

        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
        layer.borderColor = borderColor.cgColor
        isOn = false
    }

    func activateButton() {
        let color = UIColor.white
        let title = "Stop"
        let titleColor = UIColor.black
        let borderColor = UIColor.black

        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
        layer.borderColor = borderColor.cgColor
        isOn = true
    }

    @objc func buttonPressed() {
        switch isOn {
        case true:
            deactivateButton()
        default:
            activateButton()
        }
    }
}
