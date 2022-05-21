//
//  ErrorHandler.swift
//  GuaranteeWallet
//
//  Created by Jaehun Lee on 2022/03/01.
//

import Foundation

enum NetworkError: Error {
    case invalidServerResponse
    case payloadEncodingError
    case dataDecodingError
    case base64DecodingError
    case creatingQRError
}

enum QRVerificationError: Error {
    case invalidQR
}

enum TokenVerificationError: Error {
    case invalidToken
}

enum TokenSendingError: Error {
    case sendingFail
}

enum HistoryLoadingError: Error {
    case loadingFail
}

enum TokenMintingError: Error {
    case mintingFail
}

enum TokenApprovingError: Error {
    case approvingFail
}
