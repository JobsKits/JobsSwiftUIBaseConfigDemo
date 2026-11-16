//
//  JobsOCRSDKAdapter.swift
//  JobsRustOCRDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import UIKit
#if canImport(JobsRustOCR)
import JobsRustOCR
#endif

/// Keep the host buildable while the native SDK is being assembled; absence is an explicit error.
@MainActor
enum JobsOCRSDKAdapter {
    static var isAvailable: Bool {
        #if canImport(JobsRustOCR)
        return true
        #else
        return false
        #endif
    }

    static func coreVersion() -> String {
        #if canImport(JobsRustOCR)
        return JobsRustOCR.coreVersion()
        #else
        return "unavailable"
        #endif
    }

    static func sampleImage() -> UIImage? {
        #if canImport(JobsRustOCR)
        return JobsRustOCR.sampleImage()
        #else
        return nil
        #endif
    }

    static func image(from data: Data) -> UIImage? {
        #if canImport(JobsRustOCR)
        return JobsRustOCR.image(from: data)
        #else
        return nil
        #endif
    }

    static func recognize(image: UIImage, completion: @escaping @MainActor ([String: Any]?, Error?) -> Void) {
        #if canImport(JobsRustOCR)
        JobsRustOCR.recognize(image: image) { result, error in
            MainActor.assumeIsolated {
                completion(result, error)
                writeProbe(result: result, error: error)
            }
        }
        #else
        completion(nil, NSError(domain: "JobsRustOCR.SDK", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Rust OCR SDK is not installed."]))
        #endif
    }

    static func cancel() {
        #if canImport(JobsRustOCR)
        JobsRustOCR.cancel()
        #endif
    }

    private static func writeProbe(result: [String: Any]?, error: Error?) {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "--jobs-ocr-output"),
              arguments.indices.contains(index + 1), !arguments[index + 1].hasPrefix("--") else {
            return
        }
        do {
            let name = arguments[index + 1]
            let destination: URL
            if name.hasPrefix("/") {
                destination = URL(fileURLWithPath: name)
            } else {
                guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    return
                }
                destination = documents.appendingPathComponent(name)
            }
            let payload = result ?? ["ok": false, "error": error?.localizedDescription ?? "The OCR core returned no result."]
            let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
            try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: destination, options: .atomic)
        } catch {
            NSLog("[JobsOCRProbe] %@", error.localizedDescription)
        }
    }

}
