//
//  PageJumpSheet.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import SwiftUI

struct PageJumpSheet: View {
    let totalPages: Int
    let currentPage: Int
    let onSubmit: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var input: String = ""
    @State private var errorText: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Page number (1–\(totalPages))", text: $input)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .onSubmit(submit)

                    if let errorText {
                        Text(errorText)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Go to Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Go", action: submit)
                }
            }
        }
        .onAppear {
            input = "\(currentPage)"
            isFocused = true
        }
    }

    private func submit() {
        guard let number = Int(input) else {
            errorText = "Enter a valid number."
            return
        }
        guard (1...totalPages).contains(number) else {
            errorText = "Page must be between 1 and \(totalPages)."
            return
        }
        onSubmit(number)
        dismiss()
    }
}
