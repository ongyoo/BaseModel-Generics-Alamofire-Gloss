//
//  SecretKeyResponse.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Gloss

struct SecretKeyResponse: Decodable {
    let secretKey: String?
    
    init?(json: JSON) {
        self.secretKey = "secret_key" <~~ json
    }
}
