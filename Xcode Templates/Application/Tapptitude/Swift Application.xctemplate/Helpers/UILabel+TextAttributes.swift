//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

extension UITextView {
    func add(_ attributes: [NSAttributedStringKey:Any], forString string: String?, options: NSString.CompareOptions = .caseInsensitive) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.range(of: string, options: options) {
                    let nsRange = NSRange(range,in:string)
                    newAttributes.addAttributes(attributes, range: nsRange)
                    self.attributedText = newAttributes
                }
            }
        }
    }
}

extension UILabel {
    func add(_ attributes: [NSAttributedStringKey:Any], forString string: String?, options: NSString.CompareOptions = .caseInsensitive) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.range(of: string, options: options) {
                    let nsRange = NSRange(range,in:string)
                    newAttributes.addAttributes(attributes, range: nsRange)
                    self.attributedText = newAttributes
                }
            }
        }
    }
    
    func append(_ string: String?, attributes: [NSAttributedStringKey:Any]) {
        if let string = string {
            if let attributedString = attributedText?.mutableCopy() as? NSMutableAttributedString {
                let newAttributedString = NSAttributedString(string: string, attributes: attributes)
                attributedString.append(newAttributedString)
                self.attributedText = attributedString
            }
        }
    }
}


extension UIButton {
    func underline() {
        let attrs:[NSAttributedStringKey:Any] = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let attributedString = NSAttributedString(string: self.titleLabel!.text!, attributes: attrs)
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

