//
//  RustOCRDemoModel.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import Foundation
import Combine
import UIKit

@MainActor
final class RustOCRDemoModel: ObservableObject {

    @Published private(set) var image: UIImage? = JobsOCRSDKAdapter.sampleImage()
    @Published private(set) var text = ""
    @Published private(set) var statusKey = JobsOCRSDKAdapter.isAvailable ? "选择图片后开始离线识别" : "OCR 核心尚未安装"
    @Published private(set) var diagnostic = ""
    @Published private(set) var isRecognizing = false
    private var requestID = UUID()

    var coreVersion: String {
        return JobsOCRSDKAdapter.coreVersion()
    }

    func useSample() {
        select(JobsOCRSDKAdapter.sampleImage())
    }

    func selectData(_ data: Data) {
        select(JobsOCRSDKAdapter.image(from: data))
    }

    func selectCameraImage(_ image: UIImage) {
        select(image)
    }

    func copyResult() {
        guard !text.isEmpty else {
            return
        }
        UIPasteboard.general.string = text
        statusKey = "已复制识别结果"
    }

    func photoFailed(_ error: Error?) {
        guard !isRecognizing else {
            return
        }
        statusKey = "无法读取所选图片"
        diagnostic = error?.localizedDescription ?? ""
    }

    func recognize() {
        guard JobsOCRSDKAdapter.isAvailable else {
            statusKey = "OCR 核心尚未安装"
            return
        }
        guard !isRecognizing, let image else {
            return
        }
        requestID = UUID()
        let currentID = requestID
        isRecognizing = true
        text = ""
        diagnostic = ""
        statusKey = "正在本机识别，请稍候"
        JobsOCRSDKAdapter.recognize(image: image) { [weak self] result, error in
            guard let self, self.requestID == currentID else {
                return
            }
            self.isRecognizing = false
            if let error {
                self.statusKey = "识别失败，请重试"
                self.diagnostic = error.localizedDescription
            } else {
                self.text = result?["text"] as? String ?? ""
                self.statusKey = self.text.isEmpty ? "未发现可识别文字" : "离线识别完成"
                if let elapsed = result?["elapsed_ms"] as? NSNumber {
                    self.diagnostic = String(format: "%.0f ms", elapsed.doubleValue)
                }
            }
        }
    }

    func cancel() {
        guard isRecognizing else {
            return
        }
        requestID = UUID()
        JobsOCRSDKAdapter.cancel()
        isRecognizing = false
        statusKey = "已取消识别"
    }

    private func select(_ nextImage: UIImage?) {
        guard JobsOCRSDKAdapter.isAvailable else {
            statusKey = "OCR 核心尚未安装"
            return
        }
        guard !isRecognizing else {
            return
        }
        guard let nextImage else {
            photoFailed(nil)
            return
        }
        image = nextImage
        text = ""
        diagnostic = ""
        statusKey = "选择图片后开始离线识别"
    }
}
