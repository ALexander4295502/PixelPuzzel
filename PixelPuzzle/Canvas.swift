//
//  CanvasController.swift
//  PixelPuzzle
//
//  Created by Zheng on 8/2/18.
//  Copyright © 2018 Zheng. All rights reserved.
//

import UIKit

public class Canvas: UIView {
    var pixels: Array<Array<Pixel>>!
    let width: Int
    let height: Int
    let pixelSize: CGFloat
    let canvasDefaultColor: UIColor
    var viewModel: CanvasViewModel
    var lastTouched = Set<Pixel>()
    var colorMap: [UIColor: Int] = [:]
    var previousScale: CGFloat = 1.0
    var capturedImage: UIImage!


    var colorCompareThreshold: Float = 0.0

    weak var viewControllerDelegate: ViewControllerDelegate?

    public init(x: CGFloat, y: CGFloat, width: Int, height: Int, pixelSize: CGFloat, canvasColor: UIColor) {
        self.width = width
        self.height = height
        self.pixelSize = pixelSize
        canvasDefaultColor = canvasColor
        viewModel = CanvasViewModel()
        super.init(frame: CGRect(x: x, y: y, width: CGFloat(width) * pixelSize, height: CGFloat(height) * pixelSize))
        viewModel.delegate = self
        setupView()
    }

    public func updateCapturedImage(image: UIImage) {
        self.capturedImage = image
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false
    }

    private func setupView() {

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapAndDrag(sender:)))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self

        let dragGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                 action: #selector(handleTapAndDrag(sender:)))
        dragGestureRecognizer.minimumPressDuration = 0
        dragGestureRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(dragGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        addGestureRecognizer(pinchGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.minimumNumberOfTouches = 2
        addGestureRecognizer(panGestureRecognizer)

        pixels = []
        for heightIndex in 0..<height {
            pixels.append([])
            for widthIndex in 0..<width {
                let pixel = createPixel(widthIndex: widthIndex, heightIndex: heightIndex, pixelSize: pixelSize)
                pixels[heightIndex].append(pixel)
                addSubview(pixel)
            }
        }
        isUserInteractionEnabled = true
    }

    private func createPixel(widthIndex: Int, heightIndex: Int, pixelSize: CGFloat) -> Pixel {
        let pixel = Pixel(x: CGFloat(widthIndex) * pixelSize, y: CGFloat(heightIndex) * pixelSize, pixelSize: pixelSize)
        pixel.isUserInteractionEnabled = false
        return pixel
    }

    @objc private func handleTapAndDrag(sender: UIGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            check(atPoint: sender.location(in: self))
        case .ended:
            check(atPoint: sender.location(in: self))
        default: break
        }
    }

    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self)
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x,
                                          y: sender.view!.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }

    @objc private func handlePinch(sender: UIPinchGestureRecognizer) {
        self.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
        self.previousScale = sender.scale
    }

    public func check(atPoint point: CGPoint) {
        let y = Int(point.y / pixelSize)
        let x = Int(point.x / pixelSize)
        guard y < height && x < width && y >= 0 && x >= 0 else {
            return
        }
        viewModel.check(x: x, y: y)
    }

    public func draw(atPoint point: CGPoint, _color: UIColor) {
        if self.colorMap[_color] == nil {
            self.colorMap[_color] = self.colorMap.count + 1
        }
        let y = Int(point.y / pixelSize)
        let x = Int(point.x / pixelSize)
        guard y < height && x < width && y >= 0 && x >= 0 else {
            return
        }
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

    public func updateColorCompareThreshold(newValue: Float) {
        self.colorCompareThreshold = newValue
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

    public func reset() {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.center = self.superview!.center
        for row in pixels {
            for pixel in row {
                pixel.reset()
            }
        }
    }

    public func getTotalColoredPixels() -> Int {
        var count = 0
        for row in pixels {
            for pixel in row {
                if pixel.color != nil {
                    count += 1
                }
            }
        }
        return count
    }

    public func showUnfinishedPixelsHint() -> Void {
        for row in pixels {
            for pixel in row {
                if !pixel.hasAppliedColor() {
                    pixel.emphasize(start: true, backColor: nil)
                } else {
                    pixel.fadeOut(start: true)
                }
            }
        }
    }

    public func hideUnfinishedPixelsHint() -> Void {
        for row in pixels {
            for pixel in row {
                if !pixel.hasAppliedColor() {
                    pixel.emphasize(start: false, backColor: pixel.color!.withAlphaComponent(0.6))
                } else {
                    pixel.fadeOut(start: false)
                }
            }
        }
    }

}

