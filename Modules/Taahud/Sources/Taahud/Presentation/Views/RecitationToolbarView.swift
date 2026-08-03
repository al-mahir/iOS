//
//  RecitationToolbarView.swift
//  Reading
//

import SwiftUI

public struct RecitationToolbarView: View {
    let state: TaahudState
    let hardErrorCount: Int
    @Binding var selectedRules: [TajweedRule]
    @Binding var strictness: RecitationStrictness
    let onMicTapped: () -> Void
    
    private static let availableRules: [(TajweedRule, String)] = [
        (.aaredMadd, "Āreḍ Madd"),
        (.ghonna, "Ghonna"),
        (.qalqalah, "Qalqalah"),
        (.ikhfa, "Ikhfā'"),
        (.idghaam, "Idghām")
    ]

    public var body: some View {
        VStack(spacing: 12) {
            if !isIdleOrError {
                statusRow
            }

            HStack(spacing: 20) {
                Menu {
                    Picker("Strictness", selection: $strictness) {
                        Text("Lenient").tag(RecitationStrictness.lenient)
                        Text("Normal").tag(RecitationStrictness.normal)
                        Text("Strict").tag(RecitationStrictness.strict)
                    }
                    ForEach(Self.availableRules, id: \.0) { rule, label in
                        Toggle(label, isOn: ruleBinding(rule))
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                }
                .disabled(!isIdleOrError)

                Spacer()

                micButton

                Spacer()

                // Symmetry spacer so the mic button stays visually centered.
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .opacity(0)
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var isIdleOrError: Bool {
        switch state {
        case .idle, .error: return true
        default: return false
        }
    }

    private var statusRow: some View {
        HStack {
            statusLabel
            Spacer()
            if hardErrorCount > 0 {
                Label("\(hardErrorCount)", systemImage: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.footnote.weight(.semibold))
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch state {
        case .connecting:
            Label("Connecting…", systemImage: "antenna.radiowaves.left.and.right")
                .foregroundStyle(.secondary)
        case .recording:
            Label("Listening…", systemImage: "waveform")
                .foregroundStyle(.green)
        case .feedbackReceived:
            Label("Listening…", systemImage: "waveform")
                .foregroundStyle(.green)
        default:
            EmptyView()
        }
    }

    private var micButton: some View {
        Button(action: onMicTapped) {
            ZStack {
                Circle()
                    .fill(micButtonColor)
                    .frame(width: 64, height: 64)
                Image(systemName: isActive ? "stop.fill" : "mic.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel(isActive ? "Stop recitation" : "Start recitation")
    }

    private var isActive: Bool {
        switch state {
        case .connecting, .recording, .feedbackReceived: return true
        default: return false
        }
    }

    private var micButtonColor: Color {
        switch state {
        case .error: return .gray
        default: return isActive ? .red : .accentColor
        }
    }

    private func ruleBinding(_ rule: TajweedRule) -> Binding<Bool> {
        Binding(
            get: { selectedRules.contains(rule) },
            set: { isOn in
                if isOn {
                    if !selectedRules.contains(rule) { selectedRules.append(rule) }
                } else {
                    selectedRules.removeAll { $0 == rule }
                }
            }
        )
    }
}
