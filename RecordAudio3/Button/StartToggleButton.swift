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

    // MARK: Properties

    public enum BtnState {
        case start
        case waiting
        case stop
    }

    public var btnState: BtnState = .start

    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }

    func initButton() {
        btnState = .start
        layer.cornerRadius = frame.size.width / 2.0
        layer.backgroundColor = UIColor.black.cgColor
        layer.borderColor = UIColor.white.cgColor
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = .black
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 2
        addTarget(self, action: #selector(StartToggleButton.buttonPressed), for: .touchUpInside)
    }

    func listeningButton() {
        print("Button: waiting called")
    
        btnState = .waiting

        //let color = UIColor.systemGray
        let title = "Listening"
        //let titleColor = UIColor.white
        //let borderColor = UIColor.black

        setTitle(title, for: .normal)
        //setTitleColor(titleColor, for: .normal)
//        backgroundColor = color
//        layer.borderColor = borderColor.cgColor
    }

    func startButton() {
        print("Button: start called")
        if btnState == .start {
            return
        }
        btnState = .start

        //let color = UIColor.black
        let title = "Start"
//        let titleColor = UIColor.white
//        let borderColor = UIColor.white

        setTitle(title, for: .normal)
//        setTitleColor(titleColor, for: .normal)
//        backgroundColor = color
//        layer.borderColor = borderColor.cgColor
    }

    func stopButton() {
        print("Button: stop called")
        if btnState == .stop {
            print("returned early")
            return
        }

        btnState = .stop

        //let color = UIColor.white
        let title = "Stop"
//        let titleColor = UIColor.black
//        let borderColor = UIColor.black

        setTitle(title, for: .normal)
//        setTitleColor(titleColor, for: .normal)
//        backgroundColor = color
//        layer.borderColor = borderColor.cgColor
    }

    func addTimerText(text: String) {
        print("Button: addTimer called")
          btnState = .waiting
                
        let newText = "\u{2248} \(text)" //currentText ?? "" + "\n" + text
        
        print("time text = \(text)")
        titleLabel?.fadeTransition(1.0)
        setTitle(newText, for: .normal)
        titleLabel?.textAlignment = .justified
    }

    @objc func buttonPressed() {
        switch btnState {
        case .start:
            stopButton()
        case .waiting:
            startButton()
        default:
            startButton()
        }
    }
}



extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
