//
//  ImageDownSampler.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/16/25.
//

import CoreGraphics
import Foundation
import ImageIO

protocol ImageSampleable {
    func downscaleImage(
        from imageData: Data,
        targetSize: CGSize,
        croppingTo cropSize: CGSize?
    ) async throws -> Data
}

final class ImageSampler: ImageSampleable {
    private func resizeImage(to targetSize: CGSize) -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            return nil
        }
        
        return context
    }
    
    func cropCenter(of cgImage: CGImage, size: CGSize) -> CGImage? {
        let imageSize = (width: cgImage.width, height: cgImage.height)
        let cropSize = (width: Int(size.width), height: Int(size.height))
        let cropX = (imageSize.width - cropSize.width) / 2
        let cropY = (imageSize.height - cropSize.height) / 2
        let cropRect = CGRect(x: cropX, y: cropY, width: cropSize.width, height: cropSize.height)
        
        return cgImage.cropping(to: cropRect)
    }
    
    func downscaleImage(
        from imageData: Data,
        targetSize: CGSize,
        croppingTo cropSize: CGSize? = nil
    ) async throws -> Data {
        guard let cgImage = CGImage.createFromData(data: imageData) else {
            throw ImageSamplingError.invalidImageData
        }
        
        let downscaleRatio = cgImage.width > cgImage.height ?
        targetSize.height / Double(cgImage.height) :
        targetSize.width / Double(cgImage.width)
        let newSize = CGSize(
            width: Double(cgImage.width) * downscaleRatio,
            height: Double(cgImage.height) * downscaleRatio
        )
        guard let downsampledImageContext = resizeImage(to: newSize) else {
            throw ImageSamplingError.downsamplingFailed
        }
        downsampledImageContext.draw(
            cgImage,
            in: CGRect(origin: .zero, size: newSize)
        )
        guard var downsampledImage = downsampledImageContext.makeImage() else {
            throw ImageSamplingError.downsamplingFailed
        }
        if let cropSize = cropSize,
           let croppedImage = cropCenter(of: downsampledImage, size: cropSize) {
            downsampledImage = croppedImage
        }
        guard let downsampledImageData = downsampledImage.jpgData else {
            throw ImageSamplingError.downsamplingFailed
        }
        
        return downsampledImageData
    }
}

enum ImageSamplingError: LocalizedError {
    case downsamplingFailed
    case invalidImageData
    case invalidCropArea
}
