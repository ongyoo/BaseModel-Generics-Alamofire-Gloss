//
//  AccountResponse.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Gloss

struct AccountResponse: Decodable {
    var accountId: String?
    var account: GraphAccount?
    
    init?(json: JSON) {
        self.accountId = "acc_id" <~~ json
        self.account = "account" <~~ json
    }
}
