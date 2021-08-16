//
//  Authenticator.swift
//  CombineNetwork
//
//  Created by Inpyo Hong on 2021/08/16.
//

import Foundation
import Combine

enum AuthenticationError: Error {
  case loginRequired
}

class Authenticator {
  private let session: NetworkSession
  private var currentToken: Token? = Token(isValid: false)
  private let queue = DispatchQueue(label: "Autenticator.\(UUID().uuidString)")

  // this publisher is shared amongst all calls that request a token refresh
  private var refreshPublisher: AnyPublisher<Token, Error>?

  init(session: NetworkSession = URLSession.shared) {
    self.session = session
  }

    func validToken(forceRefresh: Bool = false) -> AnyPublisher<Token, Error> {
      return queue.sync { [weak self] in
        // scenario 1: we're already loading a new token
        if let publisher = self?.refreshPublisher {
          return publisher
        }

        // scenario 2: we don't have a token at all, the user should probably log in
        guard let token = self?.currentToken else {
          return Fail(error: AuthenticationError.loginRequired)
            .eraseToAnyPublisher()
        }

        // scenario 3: we already have a valid token and don't want to force a refresh
        if token.isValid, !forceRefresh {
          return Just(token)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        // scenario 4: we need a new token
        let endpoint = URL(string: "https://donnys-app.com/token/refresh")!
        let publisher = session.publisher(for: endpoint, token: nil)
          .share()
          .decode(type: Token.self, decoder: JSONDecoder())
          .handleEvents(receiveOutput: { token in
            self?.currentToken = token
          }, receiveCompletion: { _ in
            self?.queue.sync {
              self?.refreshPublisher = nil
            }
          })
          .eraseToAnyPublisher()

        self?.refreshPublisher = publisher
        return publisher
      }
    }
}
