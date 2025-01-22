//
//  Extension + UITableViewCell.swift
//  SniffMeet
//
//  Created by sole on 1/22/25.
//

import UIKit 

extension UITableViewCell {
    func configure(text: String?) {
        var content = self.contentConfiguration as? UIListContentConfiguration
        ?? self.defaultContentConfiguration()
        content.text = text
        self.contentConfiguration = content
    }
    func configure(image: UIImage, maximumSize: CGSize? = nil, cornerRadius: CGFloat? = nil) {
        var content = self.contentConfiguration as? UIListContentConfiguration
        ?? self.defaultContentConfiguration()
        if let maximumSize {
            content.imageProperties.maximumSize = maximumSize
        }
        if let cornerRadius {
            content.imageProperties.cornerRadius = cornerRadius
        }
        content.image = image
        self.contentConfiguration = content
    }
}
