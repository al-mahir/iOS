//
//  DSDropdownField.swift
//  Common
//
//  Created by Alaa Ayman on 30/07/2026.
//

import SwiftUI

public struct DSDropdownField: View {

    public let label: String?
    public let placeholder: String
    @Binding public var selection: String
    public let options: [String]
    public var leadingIcon: String? = nil
    public var errorMessage: String? = nil

    @Environment(\.dsColors) private var dsColors
    @Environment(\.isEnabled) private var isEnabled

    public init(
        label: String? = nil,
        placeholder: String = "Select option",
        selection: Binding<String>,
        options: [String],
        leadingIcon: String? = nil,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._selection = selection
        self.options = options
        self.leadingIcon = leadingIcon
        self.errorMessage = errorMessage
    }

    private var hasError: Bool { errorMessage != nil && !(errorMessage?.isEmpty ?? true) }

    private var borderColor: Color {
        if hasError { return dsColors.error }
        return dsColors.outlineVariant
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {

            if let label {
                Text(label)
                    .dsFont(DSTypography.inputLabel)
                    .foregroundColor(hasError ? dsColors.error : dsColors.textSecondary)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack {
                            Text(option)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: DSSpacing.sm) {
                    if let leadingIcon {
                        Image(systemName: leadingIcon)
                            .font(.system(size: 16))
                            .foregroundColor(dsColors.textHint)
                            .frame(width: 20)
                    }

                    Text(selection.isEmpty ? placeholder : selection)
                        .dsFont(DSTypography.inputHint)
                        .foregroundColor(
                            selection.isEmpty
                            ? dsColors.textHint
                            : (isEnabled ? dsColors.textPrimary : dsColors.textDisabled)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(dsColors.textHint)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.smMd)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(dsColors.surfaceContainerLow)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .stroke(borderColor, lineWidth: hasError ? 1.5 : 1)
                )
            }

            if let errorMessage, !errorMessage.isEmpty {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .dsFont(DSTypography.inputError)
                }
                .foregroundColor(dsColors.error)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasError)
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}
