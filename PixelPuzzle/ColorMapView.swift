//
// Created by Zheng on 8/3/18.
// Copyright (c) 2018 Zheng. All rights reserved.
//

import UIKit
import Foundation

class ColorMapView: UIView {
    let colorMap: [UIColor: Int]
    let defaultBackgroundColor: UIColor
    let defaultBorderColor: UIColor
    let stackViewContainer: UIStackView = UIStackView()

    init(colorMap: [UIColor: Int],
         backgroundColor: UIColor,
         borderColor: UIColor) {
        self.colorMap = colorMap
        self.defaultBackgroundColor = backgroundColor
        self.defaultBorderColor = borderColor
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

    func setupViews() {
        backgroundColor = self.defaultBackgroundColor

        stackViewContainer.axis = .vertical
        stackViewContainer.distribution = .fillEqually
        stackViewContainer.spacing = 1

        var _stackView = generateStackView()

        for (color, index) in self.colorMap {
            let itemView = UIView()
            itemView.backgroundColor = color
            itemView.layer.borderWidth = 1
            itemView.layer.borderColor = self.defaultBorderColor.cgColor
            _stackView.addArrangedSubview(itemView)
            if _stackView.subviews.count > 10 {
                stackViewContainer.addArrangedSubview(_stackView)
                _stackView = generateStackView()
            }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = String(index)
            label.textAlignment = .center
            itemView.addSubview(label)
            fullfillView(initView: label,
                         parentView: itemView,
                         margin: 0)
        }
        self.addSubview(stackViewContainer)
        stackViewContainer.frame = CGRect(x: 5,
                                          y: 5,
                                          width: bounds.width - 10,
                                          height: bounds.height - 10)
    }

    private func generateStackView() -> UIStackView {
        let _stackView = UIStackView()
        _stackView.axis = .horizontal
        _stackView.distribution = .fillEqually
        _stackView.spacing = 1
        return _stackView
    }
}
