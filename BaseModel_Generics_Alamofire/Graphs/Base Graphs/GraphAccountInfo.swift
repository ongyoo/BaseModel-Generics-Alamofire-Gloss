//
//  GraphAccountInfo.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Gloss

class GraphAccountInfo: Decodable, Encodable {
    var accId: String?
    var email: String?
    var facebookId: String?
    var firstName: String?
    var gender: String?
    var isVerify: Bool?
    var lastName: String?
    var mobileNo: String?
    var userImage: String?
    var userName: String?
    var address: String?
    var birthDay: String?
    
    init() {}
    
    required init?(json: JSON) {
        self.accId = "acc_id" <~~ json
        self.email = "email" <~~ json
        self.facebookId = "facebook_id" <~~ json
        self.firstName = "first_name" <~~ json
        self.gender = "gender" <~~ json
        self.isVerify = "is_verify" <~~ json
        self.lastName = "last_name" <~~ json
        self.mobileNo = "mobile_no" <~~ json
        self.userImage = "user_image" <~~ json
        self.userName = "username" <~~ json
        self.address = "address" <~~ json
        self.birthDay = "birth_day" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "acc_id" ~~> self.accId,
            "email" ~~> self.email,
            "facebook_id" ~~> self.facebookId,
            "first_name" ~~> self.firstName,
            "gender" ~~> self.gender,
            "is_verify" ~~> self.isVerify,
            "last_name" ~~> self.lastName,
            "mobile_no" ~~> self.mobileNo,
            "user_image" ~~> self.userImage,
            "username" ~~> self.userName,
            "address" ~~> self.address,
            "birth_day" ~~> self.birthDay
            ])
    }
}
