//
//  KeyboardView.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 4/8/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import UIKit

protocol SUKeyboardViewDelegate  {
    func keyboard(_ sender: SUKeyboardView, willChangeValue value: String) -> Bool
    func keyboard(_ sender: SUKeyboardView, shouldClose done: Bool)
}

class SUKeyboardView: UIView {
    fileprivate let char_clear      = "C"
    fileprivate let char_back       = "<"
    fileprivate let char_plusminus  = "±"
    fileprivate let char_point      = "."
    fileprivate let char_done       = "Done"
    fileprivate let char_minus      = "-"
    var char_initial            = "0"
    var keyboardTag:            SUKeyboardViewTag?
    
    fileprivate var titles = [String]()
    fileprivate var buttons = [UIButton]()
    fileprivate let margin: CGFloat = 24.0
    fileprivate let padding: CGFloat = 6.0
    
    fileprivate var offset = CGPoint.zero
    
    var delegate: SUKeyboardViewDelegate?
    var titleLabel, dataLabel: UILabel!
    var defaultFont: UIFont?
    
    init(frame: CGRect, delegate: SUKeyboardViewDelegate, title: String) {
        super.init(frame: frame)
        self.delegate = delegate
        
        self.backgroundColor = colors[0]
        
        titles = [char_clear, char_plusminus, char_done, "1", "2", "3", "4", "5", "6", "7", "8", "9", char_point, "0", char_back]
        
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = fonts[7]

        
        dataLabel = UILabel()
        dataLabel.text = char_initial + suffix
        dataLabel.textAlignment = .right
        dataLabel.font = fonts[7]
        
        for label in [titleLabel, dataLabel] {
            label?.numberOfLines = 0
            self.addSubview(label!)
        }
        
        let size = CGSize(width: (frame.width - margin * 2 - padding * 2) / 3, height: frame.width * 0.18)
        offset = CGPoint(x: margin, y: frame.height - margin - (size.height + padding) * 5.0 + padding)
        for y in 0...4 {
            for x in 0...2 {
                let caption = titles[y * 3 + x]
                let button = UIButton(type: .system)
                button.frame = CGRect(x: offset.x + CGFloat(x) * (size.width + padding), y: offset.y + CGFloat(y) * (size.height + padding), width: size.width, height: size.height)
                button.backgroundColor = UIColor.red
                button.layer.cornerRadius = 4.0
                button.setTitle(caption, for: UIControlState())
                if caption == char_done {
                    button.addTarget(self, action: #selector(SUKeyboardView.doClose(_:)), for: .touchUpInside)
                } else {
                    button.addTarget(self, action: #selector(SUKeyboardView.doButton(_:)), for: .touchUpInside)
                }
                button.titleLabel?.font = fonts[7]
                button.backgroundColor = colors[2]
                buttons.append(button)
                self.addSubview(button)
            }
        }
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func doClose(_ sender: UIButton) {
        if delegate != nil {
            delegate?.keyboard(self, shouldClose: true)
        }
    }
    
    func strip() -> String {
        var text = dataLabel.text as String!
        if !suffix.isEmpty && (text?.hasSuffix(suffix))! {
            text = text?.substring(to: (text?.range(of: suffix)!.lowerBound)!)
        }
        return text!
    }
    
    internal func doButton(_ sender: UIButton?) {
        var data = strip()
        let char = sender == nil ? char_initial : sender!.titleLabel?.text as String!
        if char == char_back {
            if data.characters.count > 0 && data != (char_minus + char_initial) {
                data = data.substring(to: data.characters.index(before: data.endIndex))
                if data.isEmpty {
                    data = char_initial
                } else if data == char_minus {
                    data = char_minus + char_initial
                }
            }
        } else if char == char_clear {
            data = char_initial
        } else if char == char_plusminus {
            if data.hasPrefix(char_minus) {
                data = data.substring(from: data.characters.index(after: data.startIndex))
            } else {
                data = char_minus + data
            }
        } else if char == char_point && data.range(of: char_point) != nil {
            return
        } else {
            if data == char_minus + char_initial {
                data = char_minus
            } else if data == char_initial {
                data = ""
            }
            data = data + char!
        }
        if delegate != nil {
            if delegate?.keyboard(self, willChangeValue: data) == true {
                dataLabel.text = data
            }
        } else {
            dataLabel.text = data
        }
        if !suffix.isEmpty  {
            dataLabel.text = dataLabel.text! + suffix
        }
    }
    
    var suffix: String = " sfx" {
        willSet {
            dataLabel.text = strip()
            if !newValue.isEmpty  {
                dataLabel.text = dataLabel.text! + newValue
            }
        }
    }
    
    func disable(_ captions: [String]) {
        for button in buttons {
            button.isEnabled = captions.index(of: (button.title(for: UIControlState())!)) == nil
        }
    }
    
    func update() {
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: titleLabel.frame.height * 1.6)
        
        let size = textSize(dataLabel.text!, font: dataLabel.font)
        dataLabel.frame = CGRect(x: margin, y: offset.y - size.height - margin, width: self.frame.width - margin * 2, height: size.height)
        for subview in self.subviews {
            if subview is UIButton {
                let button = subview as! UIButton
                if defaultFont != nil {
                    button.titleLabel?.font = defaultFont!
                }
                button.tintColor = self.backgroundColor
            }
        }
    }
}
