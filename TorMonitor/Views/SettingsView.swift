import SwiftUI

struct SettingsView: View {
    @ObservedObject var l10n: L10n = L10n.shared
    @StateObject private var loginService = LaunchAtLoginService.shared
    @ObservedObject private var sensorDetector = SensorDetector.shared
    @ObservedObject private var cpuToggle = CpuToggle.shared
    @ObservedObject private var cpuTempToggle = CpuTempToggle.shared
    @ObservedObject private var memoryToggle = MemoryToggle.shared
    @ObservedObject private var networkToggle = NetworkToggle.shared
    @ObservedObject private var batteryToggle = BatteryToggle.shared
    @ObservedObject private var gpuToggle = GpuToggle.shared
    @ObservedObject private var gpuTempToggle = GpuTempToggle.shared

    let manager: MonitorManager

    @State private var isQuitHovered: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(l10n.appName)")
                    .font(.system(size: 15, weight: .bold, design: .default))
                Spacer()
            }
            .padding(.horizontal, DesignTokens.defaultPadding)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .padding(.bottom, 16)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Modules Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l10n.modules.uppercased())
                            .font(DesignTokens.sectionHeaderFont)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            ModuleRowView(icon: "cpu", color: .blue, title: l10n.moduleName(.cpuUsage), isOn: cpuToggle.enabled, hasDivider: false) { newValue in
                                CpuToggle.shared.setEnabled(newValue)
                            }
                            .equatable()
                            
                            ModuleRowView(icon: "thermometer", color: .orange, title: l10n.moduleName(.cpuTemp), isOn: cpuTempToggle.enabled) { newValue in
                                CpuTempToggle.shared.setEnabled(newValue)
                            }
                            .equatable()
                            
                            ModuleRowView(icon: "memorychip", color: .green, title: l10n.moduleName(.memory), isOn: memoryToggle.enabled) { newValue in
                                MemoryToggle.shared.setEnabled(newValue)
                            }
                            .equatable()
                            
                            ModuleRowView(icon: "network", color: .cyan, title: l10n.moduleName(.network), isOn: networkToggle.enabled) { newValue in
                                NetworkToggle.shared.setEnabled(newValue)
                            }
                            .equatable()
                            
                            if BatteryService.hasBattery {
                                ModuleRowView(icon: "battery.100", color: .yellow, title: l10n.moduleName(.battery), isOn: batteryToggle.enabled) { newValue in
                                    BatteryToggle.shared.setEnabled(newValue)
                                }
                                .equatable()
                            }
                            
                            if GPUService.hasGPU {
                                ModuleRowView(icon: "display", color: .purple, title: l10n.moduleName(.gpuUsage), isOn: gpuToggle.enabled) { newValue in
                                    GpuToggle.shared.setEnabled(newValue)
                                }
                                .equatable()
                                
                                // Only show GPU Temperature if a sensor is actually accessible
                                if sensorDetector.hasGPUSensor {
                                    ModuleRowView(icon: "thermometer.sun.fill", color: .red, title: l10n.moduleName(.gpuTemp), isOn: gpuTempToggle.enabled) { newValue in
                                        GpuTempToggle.shared.setEnabled(newValue)
                                    }
                                    .equatable()
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }

                            // Fan Speed — only shown on devices with at least one fan
                            if sensorDetector.hasFan {
                                ModuleRowView(icon: "fan.fill", color: .teal, title: l10n.fanSpeed, isOn: true, isReadOnly: true)
                                    .equatable()
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .background(DesignTokens.cardBackground)
                        .overlay(DesignTokens.cardStroke())
                    }

                    // Refresh Interval Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l10n.refreshInterval.uppercased())
                            .font(DesignTokens.sectionHeaderFont)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DesignTokens.iconCornerRadius, style: .continuous)
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 26, height: 26)
                                Image(systemName: "clock")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(l10n.refreshInterval)
                                .font(DesignTokens.rowTitleFont)
                            
                            Spacer()
                            
                            PillSegmentedControl(
                                options: [3.0, 5.0, 10.0],
                                labels: { "\((Int)($0))s" },
                                selection: Binding(
                                    get: { manager.refreshInterval },
                                    set: { manager.updateRefreshInterval($0) }
                                )
                            )
                        }
                        .padding(.horizontal, DesignTokens.rowHorizontalPadding)
                        .padding(.vertical, DesignTokens.rowVerticalPadding)
                        .background(DesignTokens.cardBackground)
                        .overlay(DesignTokens.cardStroke())
                    }

                    // General Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l10n.general.uppercased())
                            .font(DesignTokens.sectionHeaderFont)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: DesignTokens.iconCornerRadius, style: .continuous)
                                        .fill(Color.indigo.opacity(0.8))
                                        .frame(width: 26, height: 26)
                                    Image(systemName: "macwindow")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text(l10n.launchAtLogin)
                                    .font(DesignTokens.rowTitleFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Toggle("", isOn: Binding(
                                    get: { loginService.isEnabled },
                                    set: { _ in loginService.toggle() }
                                ))
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.small)
                            }
                            .padding(.horizontal, DesignTokens.rowHorizontalPadding)
                            .padding(.vertical, DesignTokens.rowVerticalPadding)
                        }
                        .background(DesignTokens.cardBackground)
                        .overlay(DesignTokens.cardStroke())
                    }

                    // Quit Button
                    VStack(spacing: 8) {
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "power")
                                    .font(.system(size: 13, weight: .bold))
                                Text(l10n.quit)
                                    .font(DesignTokens.rowTitleFont)
                            }
                            .foregroundColor(isQuitHovered ? .white : .red.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isQuitHovered ? Color.red : Color.red.opacity(0.1))
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isQuitHovered = hovering
                            }
                        }
                        
                        Text("v2.0.0")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .padding(.top, 8)

                }
                .padding(.horizontal, DesignTokens.defaultPadding)
                .padding(.bottom, 20)
            }
        }
        .frame(width: DesignTokens.popoverWidth)
        .background(Color.clear) // Ensure popover transparency flows through
    }
}

