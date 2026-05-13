import Foundation
import Combine

/// Detects hardware capabilities once at app launch via SMC reads.
/// Results are hardware facts that never change at runtime, so no polling is needed.
@MainActor
final class SensorDetector: ObservableObject {
    static let shared = SensorDetector()

    /// `true` if at least one Apple Silicon GPU SMC sensor key returns a valid reading.
    /// `false` on MacBook Air M4 (and other fanless GPUs with inaccessible sensors).
    @Published private(set) var hasGPUSensor: Bool = false

    /// `true` if the SMC reports at least one fan (FNum > 0).
    /// `false` on fanless devices like MacBook Air.
    @Published private(set) var hasFan: Bool = false

    private init() {
        detectHardware()
    }

    private func detectHardware() {
        // Run detection off the main thread — SMC reads can block briefly
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let gpuSensorFound = SMCService.shared.gpuTemperatureSMC() != nil
            let fanFound = SMCService.shared.fanCount() > 0

            DispatchQueue.main.async {
                self?.hasGPUSensor = gpuSensorFound
                self?.hasFan = fanFound
#if DEBUG
                NSLog("TorMonitor SensorDetector — hasGPUSensor: %@, hasFan: %@",
                      gpuSensorFound ? "true" : "false",
                      fanFound ? "true" : "false")
#endif
            }
        }
    }
}
