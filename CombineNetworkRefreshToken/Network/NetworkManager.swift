//
//  NetworkManager.swift
//  CombineNetwork
//
//  Created by Inpyo Hong on 2021/08/16.
//

import Foundation
import Combine

struct NetworkManager {
    private let session: NetworkSession
    private let authenticator: Authenticator
    
    init(session: NetworkSession = URLSession.shared) {
      self.session = session
      self.authenticator = Authenticator(session: session)
    }
    
    func performAuthenticatedRequest() -> AnyPublisher<Response, Error> {
      let url = URL(string: "https://donnys-app.com/authenticated/resource")!

      return authenticator.validToken()
        .flatMap({ token in
          // we can now use this token to authenticate the request
          session.publisher(for: url, token: token)
        })
        .tryCatch({ error -> AnyPublisher<Data, Error> in
          guard let serviceError = error as? ServiceError,
                serviceError.errors.contains(ServiceErrorMessage.invalidToken) else {
            throw error
          }

          return authenticator.validToken(forceRefresh: true)
            .flatMap({ token in
              // we can now use this new token to authenticate the second attempt at making this request
              session.publisher(for: url, token: token)
            })
            .eraseToAnyPublisher()
        })
        .decode(type: Response.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }

}
