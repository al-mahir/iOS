//
//  SettingsRow.swift
//  Settings
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI
import Common

public enum SettingsRowTrailing {
    case navigation(action: () -> Void)
    case toggle(isOn: Binding<Bool>)
}

struct SettingsRow: View {
    let icon: String
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    var isDestructive: Bool = false
    var bundle: Bundle = CommonBundle.bundle
    var trailing: SettingsRowTrailing = .navigation(action: {})

    @Environment(\.dsColors) private var dsColors

    init(
        icon: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        isDestructive: Bool = false,
        bundle: Bundle = CommonBundle.bundle,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = isDestructive
        self.bundle = bundle
        self.trailing = .navigation(action: action)
    }

    init(
        icon: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        bundle: Bundle = CommonBundle.bundle,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = false
        self.bundle = bundle
        self.trailing = .toggle(isOn: isOn)
    }

    var body: some View {
        Group {
            switch trailing {
            case .navigation(let action):
                Button(action: action) {
                    contentView(showChevron: true)
                }
                .buttonStyle(RowPressStyle(dsColors: dsColors))
            case .toggle(let isOn):
                HStack(spacing: DSSpacing.md) {
                    iconView
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(title, bundle: bundle)
                            .dsFont(DSTypography.bodyLarge)
                            .foregroundColor(isDestructive ? dsColors.error : dsColors.textPrimary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle, bundle: bundle)
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.textSecondary)
                        }
                    }
                    
                    Spacer()

                    Toggle("", isOn: isOn)
                        .labelsHidden()
                        .tint(dsColors.primary)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.smMd)
            }
        }
    }

    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(isDestructive ? dsColors.error : dsColors.primary)
            .frame(width: 28, height: 28, alignment: .center)
    }

    private func contentView(showChevron: Bool) -> some View {
        HStack(spacing: DSSpacing.md) {
            iconView

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title, bundle: bundle)
                    .dsFont(DSTypography.bodyLarge)
                    .foregroundColor(isDestructive ? dsColors.error : dsColors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle, bundle: bundle)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dsColors.textHint)
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .contentShape(Rectangle())
    }
}

private struct RowPressStyle: ButtonStyle {
    let dsColors: DSColors

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? dsColors.surfaceVariant.opacity(0.4) : Color.clear)
    }
}
