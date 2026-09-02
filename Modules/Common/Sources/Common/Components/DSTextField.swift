//
//  DSTextField.swift
//  Common
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import SwiftUI

public struct DSTextField: View {

    public let label: String?
    public let placeholder: String
    @Binding public var text: String

    public var isSecure: Bool = false
    public var leadingIcon: String? = nil
    public var errorMessage: String? = nil
    public var keyboardType: UIKeyboardType = .default
    public var textContentType: UITextContentType? = nil
    public var autocapitalization: TextInputAutocapitalization = .sentences
    public var autocorrectionDisabled: Bool = false


    @State private var showSecureText: Bool = false
    @Environment(\.dsColors) private var dsColors
    @Environment(\.isEnabled) private var isEnabled


    public init(
        label: String? = nil,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        leadingIcon: String? = nil,
        errorMessage: String? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.leadingIcon = leadingIcon
        self.errorMessage = errorMessage
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
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

            HStack(spacing: DSSpacing.sm) {
                if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: 16))
                        .foregroundColor(dsColors.textHint)
                        .frame(width: 20)
                }

                Group {
                    if isSecure && !showSecureText {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .dsFont(DSTypography.inputHint)
                .foregroundColor(isEnabled ? dsColors.textPrimary : dsColors.textDisabled)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(autocorrectionDisabled)
                .apply(textContentType: textContentType)


                if isSecure {
                    Button {
                        showSecureText.toggle()
                    } label: {
                        Image(systemName: showSecureText ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundColor(dsColors.textHint)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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

// MARK: - Helpers

private extension View {
    @ViewBuilder
    func apply(textContentType: UITextContentType?) -> some View {
        if let type = textContentType {
            self.textContentType(type)
        } else {
            self
        }
    }
}
