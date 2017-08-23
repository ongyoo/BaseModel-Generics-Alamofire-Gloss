//
//  Response.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Gloss

struct Response<T: Decodable>: Decodable {
    let statusCode: String
    let messageTitle: String?
    let messageBody: String?
    let systemErrorMessage: String?
    var result: T?
    
    init?(json: JSON) {
        self.statusCode = ("status_code" <~~ json)!
        self.messageTitle = "message_title" <~~ json
        self.messageBody = "message_body" <~~ json
        self.systemErrorMessage = "system_error_message" <~~ json
        self.result = "result" <~~ json
    }
}
