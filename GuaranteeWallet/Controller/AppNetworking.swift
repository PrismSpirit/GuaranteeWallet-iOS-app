//
//  AppNetworking.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/02/25.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyJSON

class AppNetworking {
    static let shared = AppNetworking()
    
    private init() {
        
    }
    
    func validateAccessToken(accessToken: String) async throws -> Bool {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/node/")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        if jsonData["token_status"].stringValue == "valid" {
            return true
        }
        else {
            return false
        }
    }
    
    func getUserInfo(accessToken: String) async throws -> UserInfo {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/account/get_info")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        return UserInfo(userID: jsonData["uid"].stringValue,
                        userWallet: jsonData["account"].stringValue,
                        userType: jsonData["user_type"].stringValue,
                        publicKey: jsonData["public_key"].stringValue)
    }
    
    func signIn(userID: String, password: String) async throws -> String {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/account/login")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payloadJSON = JSON(
            [
                "user_id": userID,
                "password": password
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 401 else {
            throw NetworkError.invalidServerResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.idPWMismatch
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        return jsonData["jwt"].stringValue
    }
    
    func signUp(userID: String, password: String, walletPW: String) async throws -> String {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/account/create")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payloadJSON = JSON(
            [
                "user_id": userID,
                "password": password,
                "wallet_password": walletPW
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        return jsonData["account"].stringValue
    }

    func getTokenInfo(accessToken: String, wallet: String) async throws -> [[Card]] {
        var tokenInfoList: [[Card]] = []
        
        var idx = 0
        
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/node/getTokenInfo")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "address": wallet
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        var tmpList: [Card] = []
        for tokenInfo in jsonData["tokenInfo"].arrayValue {
            tmpList.append(Card(id: idx,
                                tokenID: String(tokenInfo["TokenID"].intValue),
                                logoImg: "logo_\(tokenInfo["Brand"].stringValue)",
                                brand: tokenInfo["Brand"].stringValue,
                                productName: tokenInfo["ProductName"].stringValue,
                                buildDate: tokenInfo["ProductionDate"].stringValue,
                                expireDate: tokenInfo["ExpirationDate"].stringValue,
                                details: tokenInfo["Details"].stringValue))
            idx += 1
        }
        tokenInfoList.append(tmpList)
        
        tmpList = []
        for approvedInfo in jsonData["approvedInfo"].arrayValue {
            tmpList.append(Card(id: idx,
                                tokenID: String(approvedInfo["TokenID"].intValue),
                                logoImg: "logo_\(approvedInfo["Brand"].stringValue)",
                                brand: approvedInfo["Brand"].stringValue,
                                productName: approvedInfo["ProductName"].stringValue,
                                buildDate: approvedInfo["ProductionDate"].stringValue,
                                expireDate: approvedInfo["ExpirationDate"].stringValue,
                                details: approvedInfo["Details"].stringValue))
            idx += 1
        }
        tokenInfoList.append(tmpList)
        print(tokenInfoList)
        return tokenInfoList
    }
    
    func loadQRCode(accessToken: String, tokenID: Int, tokenOwner: String) async throws -> UIImage {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/tokens/create_qr")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "tid": tokenID,
                "owner": tokenOwner
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }

        guard let decodedData = Data(base64Encoded: jsonData["result"].stringValue.replacingOccurrences(of: "data:image/png;base64,", with: "")) else {
            throw NetworkError.base64DecodingError
        }
        
        guard let QRCode = UIImage(data: decodedData) else {
            throw NetworkError.creatingQRError
        }
        
        return QRCode
    }
    
    func verifyToken(accessToken: String, tokenID: Int, tokenOwner: String) async throws -> [Any] {
        var result: [Any] = []
        var txHistoryList: [[String?]] = []
        
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/node/validate")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "tid": tokenID,
                "owner": tokenOwner
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TokenVerificationError.invalidToken
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
         
        result.append(
            Card(id: Int.random(in: 0...100) % 6,
                 tokenID: jsonData["info"]["TokenID"].stringValue,
                 logoImg: "logo_\(jsonData["info"]["Brand"].stringValue)",
                 brand: jsonData["info"]["Brand"].stringValue,
                 productName: jsonData["info"]["ProductName"].stringValue,
                 buildDate: jsonData["info"]["ProductionDate"].stringValue,
                 expireDate: jsonData["info"]["ExpirationDate"].stringValue,
                 details: jsonData["info"]["Details"].stringValue)
        )
        
        for tx in jsonData["txHistory"].arrayValue {
            var tmp: [String?] = []
            tmp.append(tx[0].string)
            tmp.append(tx[1].string)
            txHistoryList.append(tmp)
        }
        
        result.append(txHistoryList)
        
        return result
    }
    
    func sendToken(accessToken: String, tokenOwner: String, tokenReceiver: String, tokenID: Int, walletPW: String) async throws {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/node/transfer")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "sender": tokenOwner,
                "receiver": tokenReceiver,
                "transactor": tokenOwner,
                "tid": tokenID,
                "wallet_password": walletPW
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
                
        let (_, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TokenSendingError.sendingFail
        }
    }
    
    func getManufacturerAddress(accessToken: String, tokenID: Int) async throws -> String {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/tokens/manufacturer")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "tid": tokenID
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TokenSendingError.sendingFail
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        if jsonData["result"] != "success" {
            throw NetworkError.dataDecodingError
        }
        
        return jsonData["detail"].stringValue
    }
    
    func loadHistory(accessToken: String, address: String) async throws -> [TxHistory] {
        var histories: [TxHistory] = []
        
        var idx = 0
        
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/account/history")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "address": address
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else{
            throw HistoryLoadingError.loadingFail
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        for historyData in jsonData["result"].arrayValue {
            histories.append(TxHistory(id: idx,
                                       txType: historyData["token_from"].string == nil ? "Minted" :
                                                address == historyData["token_from"].stringValue ? "Sent" :
                                                address == historyData["token_to"].stringValue ? "Received" : "Unknown",
                                       tokenID: historyData["token_id"].intValue,
                                       tokenFrom: historyData["token_from"].string,
                                       tokenTo: historyData["token_to"].stringValue,
                                       eventTime: historyData["event_time"].stringValue))
            
            idx += 1
        }
    
        return histories
    }
    
    func mintToken(accessToken: String, address: String, productName: String, productionDate: String, expirationDate: String, details: String, walletPW: String) async throws {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/node/mint")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "address": address,
                "wallet_password": walletPW,
                "product_name": productName,
                "prod_date": productionDate,
                "exp_date": expirationDate,
                "details": details
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else{
            throw TokenMintingError.mintingFail
        }

    }
    
    func approveToken(accessToken: String, tokenReceiver: String, tokenID: Int, walletPW: String) async throws {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/node/approve")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        
        let payloadJSON = JSON(
            [
                "receiver": tokenReceiver,
                "tid": tokenID,
                "wallet_password": walletPW
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TokenApprovingError.approvingFail
        }
    }
    
    func getManufacturerAddress(tokenID: Int) async throws -> String {
        let url = URL(string: "https://capstone-337506.du.r.appspot.com/tokens/manufacturer")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payloadJSON = JSON(
            [
                "tid": tokenID
            ]
        )
        
        guard let payload = try? payloadJSON.rawData() else {
            throw NetworkError.payloadEncodingError
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GetManufacturerAddressError.getAddressFail
        }
        
        guard let jsonData = try? JSON(data: data) else {
            throw NetworkError.dataDecodingError
        }
        
        return jsonData["detail"].stringValue
    }
}
