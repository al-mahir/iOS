//
//  SheikhReviewRow.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhReviewSummaryHeader: View {
    let rating: Double
    let reviewCount: Int
    let hasVerifiedIjazah: Bool

    @Environment(\.dsColors) private var dsColors

    public init(
        rating: Double,
        reviewCount: Int,
        hasVerifiedIjazah: Bool
    ) {
        self.rating = rating
        self.reviewCount = reviewCount
        self.hasVerifiedIjazah = hasVerifiedIjazah
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            Text(String(format: "%.1f", rating))
                .dsFont(DSTypography.displayMedium)
                .foregroundColor(dsColors.textPrimary)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 2) {
                fiveStarRatingView(rating: rating)

                Text("\(reviewCount) reviews")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()

            if hasVerifiedIjazah {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(dsColors.primary)

                    Text("IJAZAH")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.primary)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .stroke(dsColors.primary.opacity(0.4), lineWidth: 1)
                        .background(Capsule().fill(dsColors.primaryContainer.opacity(0.4)))
                )
            }
        }
        .padding(DSSpacing.md)
    }

    private func fiveStarRatingView(rating: Double) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: Double(index) <= rating ? "star.fill" : (Double(index) - 0.5 <= rating ? "star.leadinghalf.filled" : "star"))
                    .font(.system(size: 14))
                    .foregroundColor(Color.orange)
            }
        }
    }
}

public struct SheikhReviewRow: View {
    let review: SheikhReview
    @Environment(\.dsColors) private var dsColors

    public init(review: SheikhReview) {
        self.review = review
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                // User Initials Avatar
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 40, height: 40)

                    Text(review.userInitials)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.primary)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userName)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                        .fontWeight(.semibold)

                    fiveStarRatingView(rating: review.rating)
                }

                Spacer()

                Text(review.dateText)
                    .dsFont(DSTypography.caption)
                    .foregroundColor(dsColors.textHint)
            }

            Text(review.commentText)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
    }

    private func fiveStarRatingView(rating: Double) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: Double(index) <= rating ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundColor(Color.orange)
            }
        }
    }
}
