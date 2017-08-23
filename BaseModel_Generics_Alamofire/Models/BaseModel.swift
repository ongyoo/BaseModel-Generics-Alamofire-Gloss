///
//  BaseModel.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Alamofire
import Security
import Gloss

struct ResponseCode {
    static let Success = "200"
    static let SecretKeyExpired = "401"
    static let NoData = "403"
    static let UpdateApp = "409"
}

struct ResultMessage {
    let title: String?
    let body: String
    let errorCode: String
    
    init(title: String?, body: String) {
        self.title = title
        self.body = body
        self.errorCode = ""
    }
    
    init(title: String?, body: String, errorCode: String) {
        self.title = title
        self.body = body
        self.errorCode = errorCode
    }
}

class BaseModel: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    var headers = [String: String]()
    var urlSession: Foundation.URLSession!
    var serverTrustPolicy: ServerTrustPolicy!
    var serverTrustPolicies: [String: ServerTrustPolicy]!
    var afManager: Alamofire.SessionManager!
    let rootCert = "*root_api"
    let corruptedCert = "corrupted"
    
    //init()
    override init() {
        super.init()
        headers.removeAll()
        headers["Content-Type"] = "application/json; charset=utf-8"
        
        /*
        let defaults = UserDefaults.standard
        if let appKey = defaults.string(forKey: Constants.UserDefaultKeys.appKey) {
            //headers[Constants.UserDefaultKeys.appKey] = appKey
            headers[Constants.UserDefaultKeys.appKey] = appKey.aesDecrypt()
        }
        if let secretKey = defaults.string(forKey: Constants.UserDefaultKeys.secretKey) {
            //headers[Constants.UserDefaultKeys.secretKey] = secretKey
            headers[Constants.UserDefaultKeys.secretKey] = secretKey.aesDecrypt()
        }
        let language = UserDefaults.standard.string(forKey: Constants.UserDefaultKeys.language) ?? Constants.LanguageCodes.thai
        headers[Constants.HeaderLanguage] = language
         */
        
        // setConfig ssl
        //self.setConfig()
    }
    
    func setConfig() {
        let pathToCert = Bundle.main.path(forResource: rootCert, ofType: "crt")
        let localCertificate:Data = try! Data(contentsOf: URL(fileURLWithPath: pathToCert!))
        self.configureAlamoFireSSLPinningWithCertificateData(localCertificate)
    }
    
    func get<Result: Decodable>(url: String, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        self.sendRequest(url: url, httpMethod: .get, responseType: responseType, completion: completion, failure: failure)
    }
    
    func post<Body: Encodable, Result: Decodable>(url: String, body: Body, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        self.sendRequest(url: url, httpMethod: .post, body: body, responseType: responseType, completion: completion, failure: failure)
    }
    
    private func sendRequest<Body: Encodable, Result: Decodable>(url: String, httpMethod: HTTPMethod, body: Body? = nil, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        var parameters: [String: Any]?
        if let unwrappedBody = body {
            parameters = unwrappedBody.toJSON()
            //debugPrint("JSON : \(unwrappedBody.toJSON())")
        }
        self.sendRequest(url: url, httpMethod: httpMethod, parameters: parameters, responseType: responseType, completion: completion, failure: failure)
    }
    
    private func sendRequest<Result: Decodable>(url: String, httpMethod: HTTPMethod, parameters: [String: Any]? = nil, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        //defaultManager
        //alamofireManager
        //Alamofire
        self.setConfig()
        afManager.request(url, method: httpMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                self.handleResponse(response, responseType: responseType, completion: completion, failure: failure, secretKeyRenewedCompletion: { () -> () in
                    self.sendRequest(url: url, httpMethod: httpMethod, parameters: parameters, responseType: responseType, completion: completion, failure: failure)
                })
        }
    }
    
    func upload<Result: Decodable>(url: String, data: Data, formData: [String: String], responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        //defaultManager
        //alamofireManager
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            for (key, value) in formData {
                multipartFormData.append(value.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
           to: url,
           method: .post,
           headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    self.handleResponse(response, responseType: responseType, completion: completion, failure: failure, secretKeyRenewedCompletion: { () -> () in
                        self.upload(url: url, data: data, formData: formData, responseType: responseType, completion: completion, failure: failure)
                    })
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    private func handleResponse<Result: Decodable>(_ response: Alamofire.DataResponse<Any>, responseType: Result.Type, completion: (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> (), secretKeyRenewedCompletion: @escaping () -> ()) {
        var _result: Result?
        var title: String?
        var successMessage: String?
        var errorMessage: String?
        var errorCode = ""
        
        if let _ = response.result.error {
            let handleErrorResult = self.handleError(error: response.result.error!)
            title = handleErrorResult.title
            errorMessage = handleErrorResult.message
            errorCode = handleErrorResult.code
        } else {
            if let value = response.result.value as? [String: AnyObject] {
                guard let resultObj = Response<Result>(json: value) else {
                    errorMessage = "Error initializing object"
                    return
                }
                
                if resultObj.statusCode == ResponseCode.Success {
                    _result = resultObj.result
                    title = resultObj.messageTitle
                    successMessage = resultObj.messageBody
                } else if resultObj.statusCode == ResponseCode.SecretKeyExpired {
                    let defaults = UserDefaults.standard
                    
                    /*
                    let appKey = defaults.string(forKey: Constants.UserDefaultKeys.appKey)?.aesDecrypt() ?? ""
                    let userKey = defaults.string(forKey: Constants.UserDefaultKeys.userKey)?.aesDecrypt() ?? ""
                    let password = defaults.string(forKey: Constants.UserDefaultKeys.password)?.aesDecrypt() ?? ""
                    */
                    
                    /*
                     let appKey = String(hexadecimal: defaults.string(forKey: Constants.UserDefaultKeys.appKey)?.hexadecimalString()! ?? "")
                     let userKey = String(hexadecimal: defaults.string(forKey: Constants.UserDefaultKeys.userKey)?.hexadecimalString()! ?? "")
                     let password = String(hexadecimal: defaults.string(forKey: Constants.UserDefaultKeys.password)? .hexadecimalString()! ?? "")
 
                    
                    let authenticationModel = AuthenticationModel(appKey: appKey)
                    authenticationModel.getSecretKey(withUserKey: userKey, andPassword: password, completion: { _ in
                        secretKeyRenewedCompletion()
                    }, failure: failure)
                     */
                    return
                } else {
                    title = resultObj.messageTitle
                    if let _ = resultObj.messageBody {
                        errorMessage = resultObj.messageBody!
                    } else {
                        if let _ = resultObj.systemErrorMessage {
                            errorMessage = resultObj.systemErrorMessage!
                        }
                    }
                    if (errorMessage ?? "").isEmpty {
                        errorMessage = "Error occurred with code " + resultObj.statusCode
                    }
                    
                    errorCode = resultObj.statusCode
                }
            }
        }
        
        if let _ = errorMessage {
            failure(ResultMessage(title: title, body: errorMessage!, errorCode: errorCode))
        } else {
            completion(_result, ResultMessage(title: title, body: successMessage ?? ""))
        }
    }
    
    private func handleError(error: Error) -> (message: String, code: String, title: String) {
        // for all error code
        // https://developer.apple.com/library/mac/documentation/Networking/Reference/CFNetworkErrors/index.html#//apple_ref/c/tdef/CFNetworkErrors
        var title = ""
        var message = ""
        
        switch Int32(error._code) {
        case CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue:
             title = "พบข้อผิดพลาด"
             message = NSLocalizedString("การเชื่อมต่ออินเตอร์เน็ตของท่านในขณะนี้ ยังไม่พร้อมใช้งาน กรุณาลองใหม่อีกครั้ง", comment: "")
 
        case CFNetworkErrors.cfNetServiceErrorTimeout.rawValue, -1001:
            title = "พบข้อผิดพลาด"
            message = NSLocalizedString("การเชื่อมต่อกับระบบในขณะนี้ ยังไม่พร้อมใช้งาน กรุณาลองใหม่อีกครั้ง", comment: "")
        default:
            message = error.localizedDescription
        }
        
        return (message, String(error._code), title)
    }
    
    // MARK: SSL Config
    
    func configureAlamoFireSSLPinningWithCertificateData(_ certificateData: Data) {
        self.serverTrustPolicy = ServerTrustPolicy.pinCertificates(
            // Getting the certificate from the certificate data
            certificates: [SecCertificateCreateWithData(nil, certificateData as CFData)!],
            // Choose to validate the complete certificate chain, not only the certificate itself
            validateCertificateChain: true,
            // Check that the certificate mathes the host who provided it
            validateHost: true
        )
        
        self.serverTrustPolicies = [
            "sg-incomeapi.claimdi.com": self.serverTrustPolicy!
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        // Time out
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 30.0
        
        self.afManager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: self.serverTrustPolicies)
        )
    }
}

