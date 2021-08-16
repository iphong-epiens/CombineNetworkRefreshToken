//
//  MockNetworkSession.swift
//  CombineNetwork
//
//  Created by Inpyo Hong on 2021/08/16.
//

import Foundation
import Combine

class MockNetworkSession: NetworkSession {
    
    func publisher(for url: URL, token: Token? = nil) -> AnyPublisher<Data, Error> {
        let statusCode: Int
        let data: Data
        
        if url.absoluteString == "https://donnys-app.com/token/refresh" {
            print("fake token refresh")
            data = """
      {
        "isValid": true
      }
      """.data(using: .utf8)!
            statusCode = 200
        } else {
            if let token = token, token.isValid {
                print("success response")
                data = """
        {
          "message": "success!"
        }
        """.data(using: .utf8)!
                statusCode = 200
            } else {
                print("not authenticated response")
                data = """
        {
          "errors": ["invalid_token"]
        }
        """.data(using: .utf8)!
                statusCode = 401
            }
        }
        
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        // Use Deferred future to fake a network call
        return Deferred {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                    promise(.success((data: data, response: response)))
                })
            }
        }
        .setFailureType(to: URLError.self)
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
