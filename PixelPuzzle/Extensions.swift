//
// Created by Zheng on 8/2/18.
// Copyright (c) 2018 Zheng. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

extension CMSampleBuffer {
    func image(orientation: UIImageOrientation = .downMirrored, scale: CGFloat = 1.0) -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)

            return UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
        }

        return nil
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func setupAVCapture() -> Void {
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        guard let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: AVCaptureDevice.Position.back) else {
            return
        }
        captureDevice = device
        beginSession()
    }

    func beginSession() -> Void {
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cannot get deviceInput")
                return
            }

            if self.session.canAddInput(deviceInput) {
                self.session.addInput(deviceInput)
            }

            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)

            if session.canAddOutput(self.videoDataOutput) {
                session.addOutput(self.videoDataOutput)
            }

            videoDataOutput.connection(with: .video)?.isEnabled = true
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect

            let rootLayer: CALayer = self.previewView.layer
            rootLayer.masksToBounds = true
            previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()

        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }

    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        let ciimage: CIImage = CIImage(cvPixelBuffer: imageBuffer)

        self.capturedImage = convert(cmage: ciimage).rotate(
                radians: Float.pi / 2)
        return
    }

    func stopCamera() {
        session.stopRunning()
    }

}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(
                radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))

        self.draw(in: CGRect(x: -self.size.width / 2,
                             y: -self.size.height / 2,
                             width: self.size.width,
                             height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func getPixelColor(atLocation location: CGPoint, withFrameSize size: CGSize) -> UIColor {
        let x: CGFloat = (self.size.width) * location.x / size.width
        let y: CGFloat = (self.size.height) * location.y / size.height

        let pixelPoint: CGPoint = CGPoint(x: x, y: y)

        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelIndex: Int = ((Int(self.size.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4

        let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
        let g = CGFloat(data[pixelIndex + 1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelIndex + 2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelIndex + 3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIView {
    func blink() {
        self.alpha = 0.2
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       options: [.curveLinear],
                       animations: { self.alpha = 1.0 },
                       completion: nil)
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var rgb: [Float] {
        let red = Float(coreImageColor.red * 255 + 0.5)
        let green = Float(coreImageColor.green * 255 + 0.5)
        let blue = Float(coreImageColor.blue * 255 + 0.5)
        return [red, green, blue]
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
        parentPixel.updateColorIndex(color: pixelState.color, index: self.colorMap[pixelState.color]!)
        parentPixel.backgroundColor = canvasDefaultColor
        let lb = UILabel(frame: CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
        lb.text = String(self.colorMap[pixelState.color]!)
        lb.textAlignment = .center
        lb.layer.borderColor = UIColor.black.cgColor
        lb.layer.borderWidth = 0.5
        parentPixel.addSubview(lb)
    }

    func checkState(x: Int, y: Int) {
        let pixel = pixels[y][x]
        if pixel.hasColorIndex() && !pixel.hasAppliedColor() && self.capturedImage != nil {
            pixel.blink()
            let originalTouchPoint = pixel.superview?.convert(pixel.frame.origin, to: nil)
            let convertedTouchPoint = getRaletivePointOnImage(point: originalTouchPoint!)
            if convertedTouchPoint != nil {
                let imageColorAtPoint = self.capturedImage.getPixelColor(atLocation: convertedTouchPoint!, withFrameSize: self.capturedImage.size)
                let _ = pixel.checkColor(color: imageColorAtPoint, threshold: self.colorCompareThreshold)
                viewControllerDelegate?.compareColorUpdate(topColor: pixel.color!, bottomColor: imageColorAtPoint)
            }
        }
//        let pixelCenterInImage = pixel.convert(pixel.center, to: )
    }
}

extension ViewController: ViewControllerDelegate {
    func compareColorUpdate(topColor: UIColor, bottomColor: UIColor) {
        self.compareTopView.backgroundColor = topColor
        self.compareBottomView.backgroundColor = bottomColor
        self.compareColorLabel.text = String(Double(compareColorDifferenceByRGB(colorA: topColor, colorB: bottomColor)).roundToDecimal(2))
    }
}

extension Canvas: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}