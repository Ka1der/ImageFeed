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
struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL
        )
    }
}
