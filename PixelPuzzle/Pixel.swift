//
// Created by Zheng on 8/3/18.
// Copyright (c) 2018 ___FULLUSERNAME___. All rights reserved.
//

import UIKit
import Foundation

class Pixel: UIView {
    var color: UIColor?
    var colorIndex: Int?
    var isApplyiedColor: Bool?

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

    public func checkColor(color: UIColor, threshold: Float) -> Int {
        if self.hasColorIndex() {
            let diff = compareColorDifferenceByGreyScale(colorA: self.color!, colorB: color)
            if (diff < threshold) {
                applySelfColor(color: color)
                return Int(1/(diff + 0.01))
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    public func hasAppliedColor() -> Bool {
        return self.color == nil || self.isApplyiedColor == true
    }

    private func applySelfColor(color: UIColor) {
        self.backgroundColor = color
        self.isApplyiedColor = true
    }

    public func reset() {
        if self.color != nil {
            self.backgroundColor = self.color!.withAlphaComponent(0.6)
            self.isApplyiedColor = false
        }
    }
}