//
//  ImageDownSampler.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/16/25.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

protocol ImageSampleable {
    func downscaleImage(
        from imageData: Data,
        targetSize: CGSize,
        croppingTo cropSize: CGSize?
    ) async throws -> Data
}

final class ImageSampler: ImageSampleable {
    private let imageCoder: CGImageCoder
    
    init(imageCoder: CGImageCoder = CGImageCoder()) {
        self.imageCoder = imageCoder
    }
    
    func downscaleImage(from imageData: Data, targetSize: CGSize, croppingTo cropSize: CGSize? = nil) throws -> Data {
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(
                imageSource, 0, nil
              ) as? [String: Any],
              let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? CGFloat,
              let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? CGFloat else {
            throw ImageSamplingError.downsamplingFailed
        }
        let imageAspectRatio = pixelWidth / pixelHeight
        let targetAspectRatio = targetSize.width / targetSize.height
        let maxPixelSize = imageAspectRatio > targetAspectRatio ? targetSize.height * imageAspectRatio : targetSize.width / imageAspectRatio
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        guard let downscaledImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, options as CFDictionary
        ) else {
            throw ImageSamplingError.downsamplingFailed
        }
        
        if let cropSize {
            let cropRect = createCropRect(
                of: CGSize(width: downscaledImage.width, height: downscaledImage.height),
                to: cropSize
            )
            guard let croppedImage = downscaledImage.cropping(to: cropRect),
                  let downsampledImageData = imageCoder.encode(
                    from: croppedImage,
                    as: .jpeg
                  ) else {
                throw ImageSamplingError.encodingFailed
            }
            return downsampledImageData
        }
        guard let downsampledImageData = imageCoder.encode(
            from: downscaledImage,
            as: .jpeg
        ) else {
            throw ImageSamplingError.encodingFailed
        }
        return downsampledImageData
    }
    
    private func createCropRect(of imageSize: CGSize, to size: CGSize) -> CGRect {
        let imageSize = (width: Int(imageSize.width), height: Int(imageSize.height))
        let cropSize = (width: Int(size.width), height: Int(size.height))
        let cropX = (imageSize.width - cropSize.width) / 2
        let cropY = (imageSize.height - cropSize.height) / 2
        return CGRect(x: cropX, y: cropY, width: cropSize.width, height: cropSize.height)
    }
}

enum ImageSamplingError: LocalizedError {
    case downsamplingFailed
    case invalidImageData
    case invalidCropArea
    case encodingFailed
}
