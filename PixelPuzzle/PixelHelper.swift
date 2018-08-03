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
    let canvas = Canvas(x: 0, y: 0, width: pixelWidth, height: pixelHeight, pixelSize: pixelSize, canvasColor: UIColor(white: 1, alpha: 0.3))

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
    print(pixelWidth, pixelHeight)
    return canvas

}

// Convert CIImage to CGImage
func convert(cmage: CIImage) -> UIImage {
    let context: CIContext = CIContext.init(options: nil)
    let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent)!
    let image: UIImage = UIImage.init(cgImage: cgImage)
    return image
}

