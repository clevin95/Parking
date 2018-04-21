//
//  BaseButton.swift
//  Parking
//
//  Created by Carter Levin on 4/20/18.
//  Copyright © 2018 CEL. All rights reserved.
//

import UIKit

class BaseButton: UIButton {
  override open var isHighlighted: Bool {
    didSet {
      alpha = isHighlighted ?  0.9 : 0.3
    }
  }
}
