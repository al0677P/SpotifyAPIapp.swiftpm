//
//  AccesTokenView.swift
//  SpotifyAPIapp
//
//  Created by Andres E. Lopez on 11/30/23.
//

import Foundation
import Foundation

struct AccessToken: Decodable {
    let token: String?
    let type: String?
    let expire: Int?
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case type = "token_type"
        case expire = "expires_in"
    }
}
