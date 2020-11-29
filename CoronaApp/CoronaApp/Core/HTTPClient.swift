//
//  HTTPClient.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import Combine

protocol HTTPClientProtocol {
    func load<R: RemoteResourse>(resource: R) -> AnyPublisher<R.RemoteResult, Error>
}

class HTTPClient: HTTPClientProtocol {
    func load<R: RemoteResourse>(resource: R) -> AnyPublisher<R.RemoteResult, Error> {
        URLSession.shared.dataTaskPublisher(for: resource.httpRequest)
            .tryMap { (data, response) -> R.RemoteResult in
                // check response if it contains invalid http status code if needed
                try resource.parse(data, response)
            }
            .eraseToAnyPublisher()
    }
}

protocol RemoteResourse {
    associatedtype RemoteResult

    var httpRequest: URLRequest { get }
    var parse: (Data, URLResponse) throws -> RemoteResult { get }
}

struct AnyRemoteResource<RemoteResult> {
    let httpRequest: URLRequest
    let parse: (Data, URLResponse) throws -> RemoteResult

    init<R: RemoteResourse>(resource: R) where R.RemoteResult == RemoteResult {
        self.httpRequest = resource.httpRequest
        self.parse = resource.parse
    }
}
