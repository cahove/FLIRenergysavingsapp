//
//  KeyPad.swift
//  FLIROneCameraSwift
//
//  Created by Christopher Hove on 10/10/2022.
//  Copyright © 2022 sample. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {

func addNumericAccessory(addPlusMinus: Bool) {
    let numberToolbar = UIToolbar()
    numberToolbar.barStyle = UIBarStyle.default

    var accessories : [UIBarButtonItem] = []

    if addPlusMinus {
        accessories.append(UIBarButtonItem(title: "+/-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusMinusPressed)))
        accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding after
    }

    accessories.append(UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadClear)))
    accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding space
    accessories.append(UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadDone)))

    numberToolbar.items = accessories
    numberToolbar.sizeToFit()

    inputAccessoryView = numberToolbar
}

@objc func numberPadDone() {
    self.resignFirstResponder()
}

@objc func numberPadClear() {
    self.text = ""
}

@objc func plusMinusPressed() {
    guard let currentText = self.text else {
        return
    }
    if currentText.hasPrefix("-") {
        let offsetIndex = currentText.index(currentText.startIndex, offsetBy: 1)
        let substring = currentText[offsetIndex...]  //remove first character
        self.text = String(substring)
    }
    else {
        self.text = "-" + currentText
    }
}

}
