//
//  RustOCRDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct RustOCRDemoView: View {

    @ObservedObject private var preferences = AppPreferences.shared
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var model = RustOCRDemoModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var cameraPresented = false
    @State private var cameraNotice = false
    @State private var cameraSettingsAvailable = false
    @State private var isVisible = false
    @State private var autoRecognitionStarted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .accessibilityLabel(AppText.text("待识别图片"))
                        .accessibilityIdentifier("jobs.ocr.preview")
                }
                Text(AppText.text("选择样例或照片，点击开始识别；结果仅在本机处理。"))
                    .font(.subheadline)
                    .foregroundStyle(secondaryTextColor)
                HStack(spacing: 8) {
                    Button {
                        selectedPhoto = nil
                        model.useSample()
                    } label: {
                        inputLabel("使用内置样例")
                    }
                    .accessibilityIdentifier("jobs.ocr.sample")
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        inputLabel("选择照片")
                    }
                    .accessibilityIdentifier("jobs.ocr.photo")
                    Button {
                        requestCamera()
                    } label: {
                        inputLabel("拍照")
                    }
                    .accessibilityIdentifier("jobs.ocr.camera")
                }
                .buttonStyle(RustOCRButtonStyle())
                .disabled(model.isRecognizing)
                Button {
                    if model.isRecognizing {
                        model.cancel()
                    } else {
                        model.recognize()
                    }
                } label: {
                    Text(AppText.text(model.isRecognizing ? "取消识别" : "开始离线识别"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(minHeight: 48)
                        .background(Color(red: 21 / 255, green: 101 / 255, blue: 192 / 255), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(RustOCRButtonStyle())
                .disabled(model.image == nil && !model.isRecognizing)
                .accessibilityIdentifier(model.isRecognizing ? "jobs.ocr.cancel" : "jobs.ocr.recognize")
                VStack(alignment: .leading, spacing: 6) {
                    if model.isRecognizing {
                        ProgressView(AppText.text(model.statusKey))
                    } else {
                        Text(AppText.text(model.statusKey))
                    }
                    if !model.diagnostic.isEmpty {
                        Text(model.diagnostic)
                            .textSelection(.enabled)
                    }
                    Text("Rust · " + model.coreVersion)
                }
                .font(.caption)
                .foregroundStyle(secondaryTextColor)
                .accessibilityIdentifier("jobs.ocr.status")
                HStack(spacing: 12) {
                    Text(AppText.text("识别结果"))
                        .font(.headline)
                    Spacer(minLength: 0)
                    Button {
                        model.copyResult()
                    } label: {
                        Text(AppText.text("复制结果"))
                            .font(.subheadline)
                            .foregroundStyle(Color(uiColor: .label))
                            .padding(.horizontal, 12)
                            .frame(minHeight: 44)
                            .background(Color(uiColor: .systemGray5), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(RustOCRButtonStyle())
                    .disabled(model.text.isEmpty)
                    .accessibilityIdentifier("jobs.ocr.copy")
                }
                if model.text.isEmpty {
                    ContentUnavailableView {
                        Label(AppText.text("尚无识别结果"), systemImage: "doc.text.viewfinder")
                    } description: {
                        Text(AppText.text("选择样例或照片，点击开始识别；结果仅在本机处理。"))
                    } actions: {
                        Button(AppText.text("重新加载")) {
                            model.recognize()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color(uiColor: .label))
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(Color(uiColor: .systemGray5), in: RoundedRectangle(cornerRadius: 10))
                        .buttonStyle(RustOCRButtonStyle())
                        .disabled(model.isRecognizing || model.image == nil)
                    }
                    .accessibilityIdentifier("jobs.ocr.empty")
                } else {
                    Text(model.text)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityIdentifier("jobs.ocr.result")
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(AppText.text("Rust OCR 离线识别"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(AppText.text("主题"), selection: $preferences.appearance) {
                        Text(AppText.text("白天")).tag("light")
                        Text(AppText.text("黑夜")).tag("dark")
                        Text(AppText.text("跟随系统")).tag("system")
                    }
                } label: {
                    Text(AppText.text("主题"))
                        .foregroundStyle(Color(uiColor: .label))
                }
                .accessibilityIdentifier("jobs.ocr.theme")
            }
        }
        .fullScreenCover(isPresented: $cameraPresented) {
            RustOCRCameraPicker { image in
                if let image {
                    model.selectCameraImage(image)
                } else {
                    model.photoFailed(nil)
                }
            }
            .ignoresSafeArea()
        }
        .alert(AppText.text("相机不可用"), isPresented: $cameraNotice) {
            Button(AppText.text("取消"), role: .cancel) {}
            if cameraSettingsAvailable {
                Button(AppText.text("打开设置")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } message: {
            Text(AppText.text(cameraSettingsAvailable ? "请在系统设置中允许相机访问。" : "此设备没有可用相机。"))
        }
        .task(id: selectedPhoto) {
            guard let selectedPhoto else {
                return
            }
            do {
                if let data = try await selectedPhoto.loadTransferable(type: Data.self), !Task.isCancelled {
                    model.selectData(data)
                } else if !Task.isCancelled {
                    model.photoFailed(nil)
                }
            } catch {
                if !Task.isCancelled {
                    model.photoFailed(error)
                }
            }
        }
        .onAppear {
            isVisible = true
            if !autoRecognitionStarted && ProcessInfo.processInfo.arguments.contains("--jobs-ocr-auto") {
                autoRecognitionStarted = true
                model.recognize()
            }
        }
        .onDisappear {
            isVisible = false
            model.cancel()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                model.cancel()
            }
        }
    }

    private var secondaryTextColor: Color {
        return colorScheme == .dark ? Color(white: 0.78) : Color(white: 0.33)
    }

    private func inputLabel(_ key: String) -> some View {
        Text(AppText.text(key))
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(uiColor: .label))
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(uiColor: .systemGray5), in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(uiColor: .separator), lineWidth: 0.5)
            }
    }

    private func requestCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraSettingsAvailable = false
            cameraNotice = true
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        /// 已授权时呈现真实照片相机。
        case .authorized:
            cameraPresented = true
        /// 权限回调只恢复当前仍可见的页面。
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    guard isVisible else {
                        return
                    }
                    if granted {
                        cameraPresented = true
                    } else {
                        cameraSettingsAvailable = true
                        cameraNotice = true
                    }
                }
            }
        /// 拒绝或受限不清空当前图片与结果。
        case .denied, .restricted:
            cameraSettingsAvailable = true
            cameraNotice = true
        /// 未知权限保持可重试提示。
        @unknown default:
            cameraSettingsAvailable = false
            cameraNotice = true
        }
    }
}

private struct RustOCRCameraPicker: UIViewControllerRepresentable {

    @Environment(\.dismiss) private var dismiss
    let selected: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {

        private let parent: RustOCRCameraPicker

        init(parent: RustOCRCameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.selected(info[.originalImage] as? UIImage)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private struct RustOCRButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
