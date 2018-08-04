//
// Created by Zheng on 8/3/18.
// Copyright (c) 2018 ___FULLUSERNAME___. All rights reserved.
//

import UIKit
import Foundation

class Pixel: UIView {
    var color: UIColor?
    var colorIndex: Int?

    public init(x: CGFloat, y: CGFloat, pixelSize: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: pixelSize, height: pixelSize))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateColorIndex(color: UIColor, index: Int) {
        self.color = color
        self.colorIndex = index
    }

    public func hasColorIndex() -> Bool {
        return self.color != nil && self.colorIndex != nil
    }

    public func getColor() -> UIColor? {
        return self.color
    }

    public func getIndex() -> Int? {
        return self.colorIndex
    }

    public func checkColor(color: UIColor, threshold: Float) -> Bool {
        if self.hasColorIndex() {
            let diff = compareColorDifferenceByRGB(colorA: self.color!, colorB: color)
            if (diff < threshold) {
                applySelfColor()
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    public func hasAppliedColor() -> Bool {
        return self.color == nil || self.backgroundColor == self.color
    }

    private func applySelfColor() {
        self.backgroundColor = self.color
    }

    public func reset() {
        if self.backgroundColor != nil {
            self.backgroundColor = nil
        }
    }
}