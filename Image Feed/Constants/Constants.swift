//
//  Constants.swift
//  Image Feed
//
//  Created by Kaider on 19.09.2024.
//

import Foundation

enum Constants {
    static let AccessKey = "mAt5FYVyrv2SvvSyk98OZZmsqj--NFNLxY8J9AY1vCU"
    static let SecretKey = "unhxiPE33mKCiGLx42T9Gz6NxVRCBJ50VyoBZV3dQLE"
    static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let AccessScope = "public+read_user+write_likes"
    static let DefaultBaseURL: URL = defaultBaseURL
    static private var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("Invalid URL")
        }
        return url
    }
}


