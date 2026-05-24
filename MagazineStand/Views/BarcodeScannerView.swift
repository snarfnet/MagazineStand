import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @StateObject private var scanner = BarcodeScannerModel()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var foundMagazine: Magazine?
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var showResult = false

    var body: some View {
        ZStack {
            Kiosk.screenBackground.ignoresSafeArea()

            if scanner.permissionGranted {
                CameraPreview(session: scanner.session)
                    .ignoresSafeArea()

                scanOverlay
            } else {
                permissionView
            }

            if showResult {
                resultOverlay
            }
        }
        .navigationTitle("バーコードスキャン")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Kiosk.ink, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            scanner.checkPermission()
        }
        .onDisappear {
            scanner.stop()
        }
        .onChange(of: scanner.scannedCode) { code in
            guard let code, !isSearching else { return }
            scanner.stop()
            searchMagazine(jan: code)
        }
    }

    private var scanOverlay: some View {
        VStack {
            Spacer()

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Kiosk.signalCyan, lineWidth: 3)
                .frame(width: 280, height: 160)
                .background(Kiosk.signalCyan.opacity(0.05))
                .overlay(
                    Text(isSearching ? "検索中..." : "バーコードをかざしてください")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 120)
                )

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Kiosk.gold)
                Text("雑誌のバーコード(JAN)を読み取って\nマイ棚に追加できます")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 60)
        }
    }

    private var permissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(Kiosk.paper.opacity(0.3))
            Text("カメラへのアクセスが必要です")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Kiosk.paper)
            Text("設定アプリからカメラの使用を許可してください")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.5))
            Button("設定を開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(Kiosk.ink)
            .padding(.horizontal, 24)
            .frame(height: 44)
            .background(Kiosk.gold, in: Capsule())
        }
    }

    private var resultOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                if let magazine = foundMagazine {
                    HStack(spacing: 14) {
                        AsyncImage(url: magazine.coverURL) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                RoundedRectangle(cornerRadius: 6).fill(Kiosk.shelf)
                            }
                        }
                        .frame(width: 60, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(magazine.title)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(Kiosk.paper)
                                .lineLimit(2)
                            Text(magazine.publisherName)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Kiosk.paper.opacity(0.6))
                            Text(magazine.formattedPrice)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Kiosk.gold)
                        }
                        Spacer()
                    }

                    let alreadyFav = favoritesManager.isFavorite(magazine)
                    Button {
                        if !alreadyFav {
                            favoritesManager.toggle(magazine)
                        }
                        resetScanner()
                    } label: {
                        Label(alreadyFav ? "追加済み — 続けてスキャン" : "マイ棚に追加", systemImage: alreadyFav ? "checkmark.circle.fill" : "bookmark.fill")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(alreadyFav ? Kiosk.paper : Kiosk.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(alreadyFav ? Kiosk.shelf : Kiosk.gold, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Kiosk.neonRed)
                        Text(error)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Kiosk.paper)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        resetScanner()
                    } label: {
                        Text("もう一度スキャン")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(Kiosk.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Kiosk.gold, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
            .padding(20)
            .background(Kiosk.ink.opacity(0.95), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Kiosk.gold.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func searchMagazine(jan: String) {
        isSearching = true
        errorMessage = nil
        foundMagazine = nil

        Task {
            do {
                let response = try await RakutenAPI.searchMagazines(keyword: jan)
                if let first = response.Items.first?.Item {
                    foundMagazine = first
                } else {
                    errorMessage = "この雑誌は見つかりませんでした\nJAN: \(jan)"
                }
            } catch {
                errorMessage = "検索に失敗しました。\n通信状況を確認してください。"
            }
            isSearching = false
            withAnimation(.snappy) { showResult = true }
        }
    }

    private func resetScanner() {
        withAnimation(.snappy) { showResult = false }
        foundMagazine = nil
        errorMessage = nil
        scanner.scannedCode = nil
        scanner.start()
    }
}

@MainActor
class BarcodeScannerModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var scannedCode: String?
    @Published var permissionGranted = false
    private var isRunning = false

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if granted { self?.setupSession() }
                }
            }
        default:
            permissionGranted = false
        }
    }

    private func setupSession() {
        guard !isRunning else { return }
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        let output = AVCaptureMetadataOutput()

        session.beginConfiguration()
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean13, .ean8]
        session.commitConfiguration()

        start()
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
        isRunning = true
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
        isRunning = false
    }
}

extension BarcodeScannerModel: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        Task { @MainActor in
            if self.scannedCode == nil {
                self.scannedCode = code
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
