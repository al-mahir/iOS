//
//  MultipartBody.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 22/07/2026.
//

import Foundation

/// A single part in a multipart/form-data request.
public struct MultipartPart {

    public let name: String
    public let data: Data
    public let mimeType: String
    public let fileName: String?

    public init(
        name: String,
        data: Data,
        mimeType: String,
        fileName: String? = nil
    ) {
        self.name = name
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }
}

public struct MultipartBody {

    public let parts: [MultipartPart]

    public init(parts: [MultipartPart]) {
        self.parts = parts
    }
}
