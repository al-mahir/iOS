//
//  SheikhMockData.swift
//  Sheikh
//

import Foundation

public enum SheikhMockData {

    public static let sampleAudio: [SheikhAudioSample] = [
        SheikhAudioSample(
            id: "audio_1",
            title: "Surah Ar-Rahman",
            riwaya: "Hafs 'an 'Asim",
            audioUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/55.mp3",
            duration: "02:15"
        ),
        SheikhAudioSample(
            id: "audio_2",
            title: "Surah Yasin",
            riwaya: "Warsh 'an Nafi'",
            audioUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/36.mp3",
            duration: "03:40"
        ),
        SheikhAudioSample(
            id: "audio_3",
            title: "Surah Al-Mulk",
            riwaya: "Qalun 'an Nafi'",
            audioUrl: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/67.mp3",
            duration: "02:50"
        )
    ]

    public static let defaultPackages: [SheikhPackage] = [
        SheikhPackage(
            id: "pkg_basic",
            nameEn: "Basic",
            nameAr: "الأساسية",
            daysPerWeek: "2 Days / Week",
            pricePerMonth: 40,
            pricePerSession: "~$5 / session",
            features: [
                "30-minute sessions",
                "Personalized revision plan",
                "Direct Sheikh feedback"
            ],
            isRecommended: false
        ),
        SheikhPackage(
            id: "pkg_intensive",
            nameEn: "Intensive",
            nameAr: "مكثفة",
            daysPerWeek: "3 Days / Week",
            pricePerMonth: 65,
            pricePerSession: "~$7.50 / session",
            features: [
                "45-minute sessions",
                "Personalized revision plan",
                "Direct feedback + recordings",
                "Priority scheduling"
            ],
            isRecommended: true
        )
    ]

    public static let defaultReviews: [SheikhReview] = [
        SheikhReview(
            id: "rev_1",
            userName: "Omar Bilal",
            userInitials: "OB",
            dateText: "14 Jul 2026",
            rating: 5.0,
            commentText: "Exceptional patience and very clear tajweed instruction. My recitation has improved rapidly — highly recommend."
        ),
        SheikhReview(
            id: "rev_2",
            userName: "Fatima Ahmed",
            userInitials: "FA",
            dateText: "8 Jul 2026",
            rating: 4.5,
            commentText: "Sheikh Ahmed is knowledgeable and methodical. The sessions are well-structured."
        ),
        SheikhReview(
            id: "rev_3",
            userName: "Bilal Hassan",
            userInitials: "BH",
            dateText: "2 Jul 2026",
            rating: 5.0,
            commentText: "The sessions have completely transformed my recitation. Jazakallah khayran!"
        )
    ]

    public static let all: [Sheikh] = [
        Sheikh(
            id: "00000000-0000-0000-0000-000000000000",
            username: "sheikh_ahmed_karimi",
            firstName: "Sheikh Ahmed",
            lastName: "Karimi",
            email: "ahmed.karimi@example.com",
            phoneNumber: "+20 100 000 0000",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 4.9,
            hasVerifiedIjazah: true,
            targetAudience: "Men & Boys 10+",
            languages: ["Arabic", "Urdu"],
            qiraat: ["Hafs", "Warsh"],
            experienceYears: 12,
            biography: "Sheikh Ahmed Karimi holds an Ijazah from Al-Azhar University in Cairo with 12 years of teaching experience. He specializes in Hafs and Warsh recitation, with students across 22 countries. His sessions focus on proper Makhraj and Tajweed rules.",
            audioSamples: sampleAudio,
            packages: defaultPackages,
            reviews: defaultReviews,
            reviewCount: 120,
            isFavorite: true
        ),
        Sheikh(
            id: "11111111-1111-1111-1111-111111111111",
            username: "sheikh_omar",
            firstName: "Omar",
            lastName: "Al-Fadel",
            email: "omar.alfadel@example.com",
            phoneNumber: "+20 100 000 0001",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 5.0,
            hasVerifiedIjazah: true,
            targetAudience: "All Ages",
            languages: ["Arabic", "English"],
            qiraat: ["Hafs", "Qalun"],
            experienceYears: 15,
            biography: "Sheikh Omar Al-Fadel is a distinguished Qari with 15 years of experience in Tajweed and Quran memorization guidance.",
            audioSamples: sampleAudio,
            packages: defaultPackages,
            reviews: defaultReviews,
            reviewCount: 95,
            isFavorite: false
        ),
        Sheikh(
            id: "22222222-2222-2222-2222-222222222222",
            username: "sheikh_ayman",
            firstName: "Ayman",
            lastName: "Jad Al-Husseini",
            email: "ayman.jad@example.com",
            phoneNumber: "+20 100 000 0002",
            profilePictureUrl: nil,
            sheikhStatus: .notAvailable,
            rate: 4.9,
            hasVerifiedIjazah: true,
            targetAudience: "Adults 18+",
            languages: ["Arabic"],
            qiraat: ["Hafs", "Warsh", "Ad-Duri"],
            experienceYears: 10,
            biography: "Sheikh Ayman specializes in advanced Qira'at narration and phonetics instruction.",
            audioSamples: sampleAudio,
            packages: defaultPackages,
            reviews: defaultReviews,
            reviewCount: 140,
            isFavorite: false
        ),
        Sheikh(
            id: "33333333-3333-3333-3333-333333333333",
            username: "sheikh_ibrahim",
            firstName: "Ibrahim",
            lastName: "Akram Al-Desouqi",
            email: "ibrahim.akram@example.com",
            phoneNumber: "+20 100 000 0003",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 4.8,
            hasVerifiedIjazah: true,
            targetAudience: "Boys 7-15",
            languages: ["Arabic", "English", "Urdu"],
            qiraat: ["Hafs"],
            experienceYears: 8,
            biography: "Sheikh Ibrahim focuses on youth memorization techniques and foundational Tajweed.",
            audioSamples: sampleAudio,
            packages: defaultPackages,
            reviews: defaultReviews,
            reviewCount: 78,
            isFavorite: false
        ),
        Sheikh(
            id: "44444444-4444-4444-4444-444444444444",
            username: "sheikh_ahmed_mousa",
            firstName: "Ahmed",
            lastName: "Mohammed Mousa",
            email: "ahmed.mousa@example.com",
            phoneNumber: "+20 100 000 0004",
            profilePictureUrl: nil,
            sheikhStatus: .notAvailable,
            rate: 5.0,
            hasVerifiedIjazah: true,
            targetAudience: "Men & Boys 10+",
            languages: ["Arabic", "English"],
            qiraat: ["Hafs", "Warsh"],
            experienceYears: 14,
            biography: "Certified teacher with ten Qira'at isnad, guiding students to complete Sanad certification.",
            audioSamples: sampleAudio,
            packages: defaultPackages,
            reviews: defaultReviews,
            reviewCount: 210,
            isFavorite: true
        )
    ]

    public static var available: [Sheikh] { all.filter { $0.isAvailable } }
    public static var inSession:  [Sheikh] { all.filter { !$0.isAvailable } }
    public static var first: Sheikh { all[0] }
}
