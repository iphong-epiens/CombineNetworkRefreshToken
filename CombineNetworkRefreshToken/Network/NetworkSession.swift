//
//  NetworkSession.swift
//  CombineNetwork
//
//  Created by Inpyo Hong on 2021/08/16.
//

import Foundation
import Combine

protocol NetworkSession: AnyObject {
  func publisher(for url: URL, token: Token?) -> AnyPublisher<Data, Error>
}

extension URLSession: NetworkSession {
  func publisher(for url: URL, token: Token?) -> AnyPublisher<Data, Error> {
    var request = URLRequest(url: url)
    if let token = token {
      request.setValue("Bearer <access token>", forHTTPHeaderField: "Authentication")
    }

    return dataTaskPublisher(for: request)
      .tryMap({ result in
        guard let httpResponse = result.response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {

          let error = try JSONDecoder().decode(ServiceError.self, from: result.data)
          throw error
        }

        return result.data
      })
      .eraseToAnyPublisher()
  }
}
