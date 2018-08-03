//
//  CanvasController.swift
//  PixelPuzzle
//
//  Created by Zheng on 8/2/18.
//  Copyright © 2018 Zheng. All rights reserved.
//

import UIKit

public class Canvas: UIView {
    class Pixel: UIView {
    }
    
    var pixels: Array<Array<Pixel>>!
    let width: Int
    let height: Int
    let pixelSize: CGFloat
    let canvasDefaultColor: UIColor
    var viewModel: CanvasViewModel
    var lastTouched = Set<Pixel>()
    var colorMap: [UIColor: Int] = [:]
    var previousScale: CGFloat = 1.0
    
    public init(x: CGFloat, y: CGFloat, width: Int, height: Int, pixelSize: CGFloat, canvasColor: UIColor) {
        self.width = width
        self.height = height
        self.pixelSize = pixelSize
        canvasDefaultColor = canvasColor
        viewModel = CanvasViewModel()
        super.init(frame: CGRect(x: x, y: y, width:  CGFloat(width) * pixelSize, height: CGFloat(height) * pixelSize))
        viewModel.delegate = self
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
//        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
//        layer.shadowOpacity = 0.5
//        layer.shadowPath = shadowPath.cgPath
    }
    
    private func setupView() {

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        addGestureRecognizer(pinchGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panGestureRecognizer)
        
        pixels = []
        for heightIndex in 0..<height {
            pixels.append([])
            for widthIndex in 0..<width {
                let pixel = createPixel(defaultColor: canvasDefaultColor)
                pixel.frame = CGRect(
                    x: CGFloat(widthIndex) * pixelSize,
                    y: CGFloat(heightIndex) * pixelSize,
                    width: pixelSize,
                    height: pixelSize
                )
                pixels[heightIndex].append(pixel)
                addSubview(pixel)
            }
        }
        isUserInteractionEnabled = true
    }
    
    private func createPixel(defaultColor: UIColor) -> Pixel {
        let pixel = Pixel()
//        pixel.backgroundColor = defaultColor
//        pixel.layer.borderWidth = 0.5
//        pixel.layer.borderColor = defaultColor.cgColor
        pixel.isUserInteractionEnabled = false
        return pixel
    }
    
//    @objc private func handleDrag(sender: UIGestureRecognizer) {
//        switch sender.state {
//        case .began, .changed:
//            draw(atPoint: sender.location(in: self))
//        case .ended:
//            draw(atPoint: sender.location(in: self))
//            viewModel.endDrawing()
//        default: break
//        }
//    }

    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self)
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }

    @objc private func handlePinch(sender: UIPinchGestureRecognizer) {
        self.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
        self.previousScale = sender.scale
    }

    public func draw(atPoint point: CGPoint, _color: UIColor) {
        if self.colorMap[_color] == nil {
            self.colorMap[_color] = self.colorMap.count + 1
        }
        let y = Int(point.y / pixelSize)
        let x = Int(point.x / pixelSize)
        guard y < height && x < width && y >= 0 && x >= 0 else { return }
        viewModel.drawAt(x: x, y: y, color: _color)
    }

    public func addIndex(atPoint point: CGPoint, _color: UIColor) {
        if self.colorMap[_color] == nil {
            self.colorMap[_color] = self.colorMap.count + 1
        }
        let y = Int(point.y / pixelSize)
        let x = Int(point.x / pixelSize)
        guard y < height && x < width && y >= 0 && x >= 0 else {
            return
        }
        viewModel.addIndexAt(x: x, y: y, color: _color)
    }
    
    private func removeGrid() {
        for row in pixels {
            for pixel in row {
                pixel.layer.borderWidth = 0
            }
        }
    }
    
    private func addGrid() {
        for row in pixels {
            for pixel in row {
                pixel.layer.borderWidth = 0.5
            }
        }
    }
    
    func makeImageFromSelf() -> UIImage {
        removeGrid()
        UIGraphicsBeginImageContext(self.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        addGrid()
        return image!
    }
}

extension Canvas: CanvasDelegate {
    func colorChanged(newPixelState pixelState: PixelState) {
        pixels[pixelState.y][pixelState.x].backgroundColor = pixelState.color
    }
    
    func clearCanvas() {
        for row in pixels {
            for pixel in row {
                pixel.backgroundColor = canvasDefaultColor
            }
        }
    }

    func addIndex(newPixelState pixelState: PixelState) {
        let parentPixel = pixels[pixelState.y][pixelState.x]
        guard self.colorMap[pixelState.color] != nil else {
            print("cannot find color!!")
            return
        }
        let lb = UILabel(frame: CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
        lb.text = String(self.colorMap[pixelState.color]!)
        lb.textAlignment = .center
        lb.layer.borderColor = UIColor.black.cgColor
        lb.layer.borderWidth = 0.5
        lb.backgroundColor = canvasDefaultColor
        parentPixel.addSubview(lb)
    }
}

extension Canvas: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

