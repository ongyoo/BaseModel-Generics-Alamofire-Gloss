//
//  GraphAccount.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Gloss

struct GraphAccount: Decodable {
    var accountId: String?
    var address: String?
    var companyId: String?
    var email: String?
    var facebookId: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    var imageUrl: String?
    var telNo: String?
    var username: String?
    
    init?(json: JSON) {
        self.accountId = "acc_id" <~~ json
        self.address = "address" <~~ json
        self.companyId = "com_id" <~~ json
        self.email = "email" <~~ json
        self.facebookId = "facebook_id" <~~ json
        self.firstName = "first_name" <~~ json
        self.lastName = "last_name" <~~ json
        self.password = "password" <~~ json
        self.imageUrl = "image_url" <~~ json
        self.telNo = "tel" <~~ json
        self.username = "username" <~~ json
    }
}
