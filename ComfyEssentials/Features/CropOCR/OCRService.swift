//
//  OCRService.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import Vision
import CoreGraphics

enum OCRService {
    static func extractText(from image: CGImage) async -> String {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    print("OCR error:", error)
                    continuation.resume(returning: "")
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []

                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                continuation.resume(returning: text)
            }

            request.revision = VNRecognizeTextRequestRevision3
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: image)

            do {
                try handler.perform([request])
            } catch {
                print("OCR perform error:", error)
                continuation.resume(returning: "")
            }
        }
    }
}
