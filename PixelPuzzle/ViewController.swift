//
//  ViewController.swift
//  PixelPuzzle
//
//  Created by Zheng on 8/2/18.
//  Copyright © 2018 Zheng. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    var previewView: UIView!
    var pixelBoardView: UIView!
    var canvas: Canvas!
    var gesture: UIPinchGestureRecognizer!

    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()

    // Properties for Analysing Captured Image
    var capturedImage: UIImage!
    var analyseCapturedImageTimer: Timer!
    var capturedImageContainer: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCameraView()
        initializePixelBoard(image: #imageLiteral(resourceName: "cool"))
        self.setupAVCapture()
        self.setUpcapturedImageContainer()
        self.setUpAnalyseCapturedImageTime()
    }

    func setUpcapturedImageContainer() {
        self.capturedImageContainer = UIImageView(frame: CGRect(x: 30, y: 50, width: 50, height: 80))
        self.capturedImageContainer.contentMode = UIViewContentMode.scaleAspectFit
        self.capturedImageContainer.layer.borderWidth = 1
        self.capturedImageContainer.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(self.capturedImageContainer)
    }

    func initializeCameraView() -> Void {
        previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        view.addSubview(previewView)
    }

    func initializePixelBoard(image: UIImage) -> Void {
        pixelBoardView = UIView(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        view.addSubview(pixelBoardView)
        fullfillView(initView: pixelBoardView, margin: 10)

        let imageSample: UIImage = image
        if imageSample.size.width > imageSample.size.height {
            pixelBoardView.contentMode = UIViewContentMode.scaleAspectFill
        } else {
            pixelBoardView.contentMode = UIViewContentMode.scaleAspectFit
        }
        canvas = scanImage(image: #imageLiteral(resourceName: "cool"), viewWidth: UIScreen.main.bounds.size.width, viewHeight: UIScreen.main.bounds.size.height)
        canvas.center = self.view.convert(self.view.center, from: self.view.superview)
        self.view.addSubview(canvas)

    }

    func setUpAnalyseCapturedImageTime() -> Void {
        self.analyseCapturedImageTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.analyseCapturedImage), userInfo: nil, repeats: true)
    }

    @objc func analyseCapturedImage() -> Void {
        self.capturedImageContainer.image = self.capturedImage.rotate(radians: Float.pi / 2)
        return
    }

    func fullfillView(initView: UIView, margin: CGFloat) -> Void {
        initView.translatesAutoresizingMaskIntoConstraints = false
        initView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: margin).isActive = true
        initView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: margin).isActive = true
        initView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: margin).isActive = true
        initView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -1 * margin).isActive = true
    }

    override var shouldAutorotate: Bool {
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
                   UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
                   UIDevice.current.orientation == UIDeviceOrientation.unknown {
            return false
        } else {
            return true
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

