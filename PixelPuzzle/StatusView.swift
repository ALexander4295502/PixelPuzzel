//
// Created by Zheng on 8/7/18.
// Copyright (c) 2018 ___FULLUSERNAME___. All rights reserved.
//

import UIKit
import Foundation

class StatusView: UIView {
    var totalPixels: Int!
    var finishedPixels: Int!
    var score: Int!
    var pixelNumStatusLabel: UILabel!
    var scoreBoardLabel: UILabel!

    weak var viewControllerDelegate: ViewControllerDelegate?

    init(totalPixels: Int) {
        self.totalPixels = totalPixels
        self.finishedPixels = 0
        self.score = 0
        super.init(frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width - 2 * Metrics.regular,
                height: Metrics.regular * 5
        ))
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() -> Void {
        addHelpButton()
        addStatusBoardView()
    }

    func addHelpButton() -> Void {
        let helpButton = UIButton(
                frame: CGRect(
                        x: self.bounds.width / 2 - Metrics.regular * 2,
                        y: Metrics.regular * 4,
                        width: Metrics.regular * 4,
                        height: Metrics.regular * 2
                )
        )
        helpButton.backgroundColor = UIColor.white
        helpButton.setTitle("Helper", for: .normal)
        helpButton.setTitleColor(UIColor.blue, for: .normal)
        helpButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 10)
        helpButton.titleLabel!.adjustsFontSizeToFitWidth = true
        helpButton.layer.borderColor = UIColor.blue.cgColor
        helpButton.layer.borderWidth = 1
        helpButton.layer.cornerRadius = 5
        helpButton.addTarget(self, action: #selector(helpButtonActionDown(sender:)), for: .touchDown)
        helpButton.addTarget(self, action: #selector(helpButtonActionUp(sender:)), for: [.touchUpInside, .touchUpOutside])
        self.addSubview(helpButton)
    }

    @objc func helpButtonActionDown(sender: UIButton!) {
        self.viewControllerDelegate?.showUnfinishedPixelsHint()
    }

    @objc func helpButtonActionUp(sender: UIButton!) {
        self.viewControllerDelegate?.hideUnfinishedPixelsHint()
    }

    func addStatusBoardView() -> Void {
        self.pixelNumStatusLabel = UILabel(
                frame: CGRect(
                        x: 0,
                        y: 0,
                        width: self.bounds.size.width / 2 - Metrics.regular,
                        height: Metrics.regular * 3
                )
        )
        self.scoreBoardLabel = UILabel(
                frame: CGRect(
                        x: self.bounds.size.width / 2 + Metrics.regular,
                        y: 0,
                        width: self.bounds.size.width / 2 - Metrics.regular,
                        height: Metrics.regular * 3
                )
        )
        self.addSubview(pixelNumStatusLabel)
        self.addSubview(scoreBoardLabel)
        self.pixelNumStatusLabel.layer.borderColor = UIColor.black.cgColor
        self.pixelNumStatusLabel.layer.borderWidth = 1
        self.pixelNumStatusLabel.textAlignment = .center
        self.pixelNumStatusLabel.textColor = UIColor.black
        self.scoreBoardLabel.layer.borderColor = UIColor.black.cgColor
        self.scoreBoardLabel.layer.borderWidth = 1
        self.scoreBoardLabel.textAlignment = .center
        self.scoreBoardLabel.textColor = UIColor.black
        self.updateStatusBoard()
    }

    public func updateStatus(score: Int) {
        self.score! += score
        self.finishedPixels! += 1
        self.updateStatusBoard()
        if self.finishedPixels == self.totalPixels {
            showSumView()
        }
    }

    private func showSumView() {
        let accuracy = (Double(self.score) / Double(self.totalPixels * 100)).roundToDecimal(4) * 100.0
        let alert = UIAlertController(
                title: "Congrats! You made it!🎉🎉🎉",
                message: "You total score is \(self.score!) \n and your accuracy is \(accuracy)%",
                preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.viewControllerDelegate?.showAlert(alert: alert)
    }

    public func resetStatus() {
        self.score = 0
        self.finishedPixels = 0
        self.updateStatusBoard()
    }

    private func updateStatusBoard() {
        self.pixelNumStatusLabel.text = "Finished: \(self.finishedPixels!)/\(self.totalPixels!)"
        self.scoreBoardLabel.text = "Scores: \(self.score!)"

    }
}