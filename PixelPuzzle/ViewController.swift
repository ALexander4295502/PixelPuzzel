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
    var sliderIndicator: UILabel!

    var compareColorView: UIView!
    var compareTopView: UIView!
    var compareBottomView: UIView!
    var compareColorLabel: UILabel!

    var statusView: StatusView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCameraView()
        initializePixelBoard(image: #imageLiteral(resourceName: "cool"))
        self.setupAVCapture()
        self.setupCapturedImageContainer()
        self.setupCompareColorView()
        self.setupAnalyseCapturedImageTime()
    }

    func setupCapturedImageContainer() {
        self.capturedImageContainer = UIImageView(frame: CGRect(x: 30,
                                                                y: 50,
                                                                width: 50,
                                                                height: 80))
        self.capturedImageContainer.contentMode = UIViewContentMode.scaleAspectFit
        self.capturedImageContainer.layer.borderWidth = 1
        self.capturedImageContainer.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(self.capturedImageContainer)
    }

    func setupCompareColorView() {
        self.canvas.viewControllerDelegate = self
        self.statusView.viewControllerDelegate = self
        self.compareColorView = UIView(frame: CGRect(x: 90, y: 50, width: 50, height: 80))
        self.compareColorLabel = UILabel(frame: CGRect(x: 90, y: 130, width: 50, height: 30))
        self.compareColorLabel.text = "0.00"
        self.compareColorLabel.textAlignment = .center
        self.compareColorView.layer.borderWidth = 1
        let compareColorViewContainer = UIStackView()
        compareColorViewContainer.backgroundColor = UIColor.black
        compareColorViewContainer.axis = .vertical
        compareColorViewContainer.distribution = .fillEqually
        self.compareColorView.layer.borderColor = UIColor.black.cgColor
        self.compareTopView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.compareBottomView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        compareColorViewContainer.addArrangedSubview(self.compareTopView)
        compareColorViewContainer.addArrangedSubview(self.compareBottomView)
        compareColorViewContainer.frame = self.compareColorView.bounds
        self.compareColorView.addSubview(compareColorViewContainer)
        self.view.addSubview(self.compareColorView)
        self.view.addSubview(compareColorLabel)
    }

    func initializeCameraView() -> Void {
        previewView = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.size.width,
                                           height: UIScreen.main.bounds.size.height))
        view.addSubview(previewView)
    }

    func initializePixelBoard(image: UIImage) -> Void {
        pixelBoardView = UIView(frame: CGRect(x: 10,
                                              y: 10,
                                              width: 10,
                                              height: 10))
        view.addSubview(pixelBoardView)
        fullfillView(initView: pixelBoardView,
                     parentView: self.view,
                     margin: 10)

        let imageSample: UIImage = image
        if imageSample.size.width > imageSample.size.height {
            pixelBoardView.contentMode = UIViewContentMode.scaleAspectFill
        } else {
            pixelBoardView.contentMode = UIViewContentMode.scaleAspectFit
        }

        addCanvas()
//        addColorMap()
        addStatusView()
        addSlider()
        addButton()
    }

    func addCanvas() -> Void {
        canvas = scanImage(image: #imageLiteral(resourceName: "cool"),
                           viewWidth: UIScreen.main.bounds.size.width,
                           viewHeight: UIScreen.main.bounds.size.height
        )
        canvas.center = self.view.convert(self.view.center,
                                          from: self.view.superview)
        self.view.addSubview(canvas)
    }

    func addColorMap() -> Void {
        let colorMapView = ColorMapView(colorMap: canvas.colorMap,
                                        backgroundColor: UIColor(red: 0,
                                                                 green: 0,
                                                                 blue: 0,
                                                                 alpha: 0.5),
                                        borderColor: UIColor.white)
        colorMapView.center = self.view.convert(CGPoint(x: self.view.center.x,
                                                        y: self.view.center.y + (
                                                                self.view.bounds.height - colorMapView.bounds.height) / 2 - 34),
                                                from: self.view.superview)
        self.view.addSubview(colorMapView)
    }

    func addStatusView() -> Void {
        statusView = StatusView(totalPixels: self.canvas.getTotalColoredPixels())
        statusView.center = self.view.convert(CGPoint(x: self.view.center.x,
                                                        y: self.view.center.y + (
                                                                self.view.bounds.height - statusView.bounds.height) / 2 - 34),
                                                from: self.view.superview)
        self.view.addSubview(statusView)
    }

    func setupAnalyseCapturedImageTime() -> Void {
        self.analyseCapturedImageTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(self.updateCapturedImage),
                userInfo: nil,
                repeats: true)
    }

    @objc func updateCapturedImage() -> Void {
        self.capturedImageContainer.image = self.capturedImage
        self.canvas.updateCapturedImage(image: self.capturedImage)
        return
    }

    override var shouldAutorotate: Bool {
        return UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                || UIDevice.current.orientation == UIDeviceOrientation.unknown
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addSlider() {
        let mySlider = UISlider(frame: CGRect(x: 140, y: 100, width: 200, height: 20))
        self.sliderIndicator = UILabel(frame: CGRect(x: 140, y: 70, width: 200, height: 20))
        self.sliderIndicator.textAlignment = .center
        self.sliderIndicator.text = "THOLD: 0"
        self.sliderIndicator.textColor = UIColor.black
        mySlider.minimumValue = 0
        mySlider.maximumValue = 100
        mySlider.isContinuous = true
        mySlider.tintColor = UIColor.blue
        mySlider.addTarget(self, action: #selector(sliderDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(self.sliderIndicator)
        self.view.addSubview(mySlider)
    }

    func addButton() {
        let resetButton = UIButton(frame: CGRect(x: 320, y: 70, width: 40, height: 20))
        resetButton.backgroundColor = UIColor.white
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor.blue, for: .normal)
        resetButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 10)
        resetButton.titleLabel!.adjustsFontSizeToFitWidth = true
        resetButton.layer.borderColor = UIColor.blue.cgColor
        resetButton.layer.borderWidth = 1
        resetButton.layer.cornerRadius = 5
        resetButton.addTarget(self, action: #selector(resetButtonAction(sender:)), for: .touchUpInside)
        self.view.addSubview(resetButton)
    }

    @objc func resetButtonAction(sender: UIButton!) {
        self.canvas.reset()
        self.statusView.resetStatus()
    }

    @objc func sliderDidChange(sender: UISlider!) {
        self.canvas.updateColorCompareThreshold(newValue: sender.value/100.0)
        self.sliderIndicator.text = "THOLD: \(Double(sender.value/100.0).roundToDecimal(2))"
    }
}

