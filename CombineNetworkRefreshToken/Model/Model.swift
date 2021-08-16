//
//  Model.swift
//  CombineNetwork
//
//  Created by Inpyo Hong on 2021/08/16.
//

import Foundation
import Combine

struct Token: Decodable {
  let isValid: Bool
}

struct Response: Decodable {
  let message: String
}

enum ServiceErrorMessage: String, Decodable, Error {
  case invalidToken = "invalid_token"
}

struct ServiceError: Decodable, Error {
  let errors: [ServiceErrorMessage]
}
