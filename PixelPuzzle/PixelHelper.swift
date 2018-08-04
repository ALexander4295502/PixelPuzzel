//
//  PixelHelper.swift
//  PixelPuzzle
//
//  Created by Zheng on 8/2/18.
//  Copyright © 2018 Zheng. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

func scanImage(image: UIImage, viewWidth: CGFloat, viewHeight: CGFloat) -> Canvas? {
    let pixelWidth = Int(image.size.width)
    let pixelHeight = Int(image.size.height)

    guard let pixelData = image.cgImage?.dataProvider?.data else {
        return nil
    }
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    let pixelSize = viewWidth / CGFloat(pixelWidth)
    let canvas = Canvas(x: 0,
                        y: 0,
                        width: pixelWidth,
                        height: pixelHeight,
                        pixelSize: pixelSize,
                        canvasColor: UIColor(white: 1, alpha: 0.3)
                        )

    for x in 0..<pixelWidth {
        for y in 0..<pixelHeight {
            let point = CGPoint(x: x, y: y)
            let pixelInfo: Int = ((pixelWidth * Int(point.y)) + Int(point.x)) * 4
            let color = UIColor(red: CGFloat(data[pixelInfo]) / 255.0,
                                green: CGFloat(data[pixelInfo + 1]) / 255.0,
                                blue: CGFloat(data[pixelInfo + 2]) / 255.0,
                                alpha: CGFloat(data[pixelInfo + 3]) / 255.0)
            if color.cgColor.alpha == 0.0 {
                continue
            }
            canvas.addIndex(atPoint: CGPoint(x: CGFloat(x) * pixelSize, y: CGFloat(y) * pixelSize), _color: color)
        }
    }
    return canvas

}

// Convert CIImage to CGImage
func convert(cmage: CIImage) -> UIImage {
    let context: CIContext = CIContext.init(options: nil)
    let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent)!
    let image: UIImage = UIImage.init(cgImage: cgImage)
    return image
}

func fullfillView(initView: UIView, parentView: UIView, margin: CGFloat) -> Void {
    initView.translatesAutoresizingMaskIntoConstraints = false
    initView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: margin).isActive = true
    initView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: margin).isActive = true
    initView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: margin).isActive = true
    initView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -1 * margin).isActive = true
}

func compareColorDifferenceByRGB(colorA: UIColor, colorB: UIColor) -> Float {
    let denominator = sqrtf(pow(255, 2) * 3.0)
    return sqrtf(pow((colorA.rgb[0] - colorB.rgb[0]), 2) + pow((colorA.rgb[1] - colorB.rgb[1]), 2) + pow((colorA.rgb[2] - colorB.rgb[2]), 2)) / denominator
}

func getRaletivePointOnImage(point: CGPoint) -> CGPoint? {
    let CONVERTED_RATE = CGFloat(480.0/375.0)
    let SCREEN_TOP_PADDING = CGFloat(156)
//    let SCREEN_BOTTOM_PADDING = CGFloat(156)
    let VIDEO_PREVIEW_HEIGHT = CGFloat(500)
    let SCREEN_WIDTH = CGFloat(375)
    if  0 <= point.x  && point.x <= SCREEN_WIDTH && SCREEN_TOP_PADDING <= point.y && point.y <= SCREEN_TOP_PADDING + VIDEO_PREVIEW_HEIGHT {
        let convertedPoint = CGPoint(x: point.x * CONVERTED_RATE, y: (point.y - SCREEN_TOP_PADDING) * CONVERTED_RATE)
        return convertedPoint
    } else {
        return nil
    }
}

