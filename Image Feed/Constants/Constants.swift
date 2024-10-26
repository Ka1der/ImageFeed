//
//  Constants.swift
//  Image Feed
//
//  Created by Kaider on 19.09.2024.
//

import Foundation

enum Constants {
    static let accessKey = "mAt5FYVyrv2SvvSyk98OZZmsqj--NFNLxY8J9AY1vCU"
    static let secretKey = "unhxiPE33mKCiGLx42T9Gz6NxVRCBJ50VyoBZV3dQLE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = defaultBaseURLGet
    static private var defaultBaseURLGet: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("Invalid URL")
        }
        return url
    }
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
