//
//  SnakeCaseJSONDecoder.swift
//  Image Feed
//
//  Created by Kaider on 19.10.2024.
//

import Foundation

final class SnakeCaseJSONDecoder: JSONDecoder, @unchecked Sendable {
    override init() {
        super .init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
