//
//  Customization.swift
//  github-usersbook
//
//  Created by Łukasz Gajewski on 2/8/19.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var colors: (start: UIColor, end: UIColor)? {
        didSet { updateLayer() }
    }
    
    private func updateLayer() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = colors.map { [$0.start.cgColor, $0.end.cgColor] }
    }
}
