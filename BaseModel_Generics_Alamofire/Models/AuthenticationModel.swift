//
//  AuthenticationModel.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation

class AuthenticationModel: BaseModel {
    
    init(appKey: String) {
        //let defaults = UserDefaults.standard
        //defaults.set(appKey.aesEncrypt(), forKey: Constants.UserDefaultKeys.appKey)
        super.init()
    }
    
    func checkSSLPinning(completion: @escaping (_ validate: Bool) -> ()) {
        let url = "url"
        super.get(url: url, responseType: EmptyResponse.self, completion: { result, message in
            completion(true)
        }, failure: {error in
            completion(false)
        })
    }
    
    //Method GET
    func getSecretKey(withUserKey userKey: String, andPassword password: String, completion: @escaping (_ secretKey: String?) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        /*
        headers["user_key"] = userKey
        headers["password"] = password
         */
        let url = "url"
        super.get(url: url, responseType: SecretKeyResponse.self, completion: { result, _ in
            var secretKey: String?
            if let _ = result {
                secretKey = result!.secretKey
            }
            completion(secretKey)
            }, failure: failure)
    }
    
    //Method POST
    func testPost(withAccount account: GraphAccount, completion: @escaping (_ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        var request = AccountIdRequest()
        request.username = account.username
        request.password = account.password
       
        let url = "url"
        super.post(url: url, body: request, responseType: EmptyResponse.self, completion: { result, message in
            completion(message)
        }, failure: failure)
    }
}
