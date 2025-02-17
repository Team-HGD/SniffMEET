//
//  Extension + GIFImageView.swift
//  SniffMeet
//
//  Created by 배현진 on 2/13/25.
//

import UIKit

class GIFImageView: UIImageView {
    init?(named gifName: String) {
        super.init(frame: .zero)

        let options: [CFString: Any] = [kCGImageSourceShouldCache: false]

        guard let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
              let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
              let source = CGImageSourceCreateWithData(gifData as CFData, options as CFDictionary) else {
            return nil
        }

        var images = [UIImage]()
        var duration: Double = 0

        let frameCount = CGImageSourceGetCount(source)
        for frame in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, frame, nil) else { continue }
            images.append(UIImage(cgImage: cgImage))

            let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, frame, nil) as? [String: Any]
            let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
            let frameDuration = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0
            duration += frameDuration
        }

//        let imageView = UIImageView()
        self.animationImages = images
        self.animationDuration = duration
        self.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
