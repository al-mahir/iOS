//
//  AgoraVideoView.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import SwiftUI
import UIKit

public struct AgoraVideoView: UIViewRepresentable {

    private let sessionManager: AgoraSessionManaging

    private let uid: Int?

    public init(sessionManager: AgoraSessionManaging, uid: Int? = nil) {
        self.sessionManager = sessionManager
        self.uid = uid
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        bindCanvas(to: view)
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        bindCanvas(to: uiView)
    }

    private func bindCanvas(to view: UIView) {
        if let uid = uid, uid != 0 {
            sessionManager.setupRemoteVideoCanvas(view, forUid: uid)
        } else {
            sessionManager.setupLocalVideoCanvas(view)
        }
    }
}
