//
//  AccountIdRequest.swift
//  Claim Di
//
//  Created by Kakashi on 09/16/2016.
//  Copyright © 2016 Anywhere 2 Go. All rights reserved.
//

import Foundation
import Gloss

struct AccountIdRequest: Encodable {
    var username: String?
    var password: String?
    var accSecretKey: String?
    
    init() {}
    
    func toJSON() -> JSON? {
        return jsonify([
            "username" ~~> self.username,
            "password" ~~> self.password,
            "acc_secret_key" ~~> self.accSecretKey
            ])
    }
}
