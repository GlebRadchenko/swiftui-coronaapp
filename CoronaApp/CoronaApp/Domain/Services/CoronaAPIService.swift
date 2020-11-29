//
//  CoronaAPIService.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import Combine

//https://documenter.getpostman.com/view/10808728/SzS8rjbc#00030720-fae3-4c72-8aea-ad01ba17adf8
protocol CoronaAPIServiceProtocol {
    func summary() -> AnyPublisher<SummaryResponse, Error>
}

class CoronaAPIService: CoronaAPIServiceProtocol {
    @Injected private var client: HTTPClientProtocol

    private let decoder = JSONDecoder()
    private let baseURL = URL(string: "https://api.covid19api.com/")!

    func summary() -> AnyPublisher<SummaryResponse, Error> {
        client.load(resource: CoronaAPI.Summary(decoder: decoder, baseURL: baseURL))
    }
}

struct CoronaAPI {
    struct Summary: RemoteResourse {
        typealias RemoteResult = SummaryResponse

        let decoder: JSONDecoder
        let baseURL: URL

        var parse: (Data, URLResponse) throws -> SummaryResponse {
            return { [decoder] data, _ in
                try decoder.decode(RemoteResult.self, from: data)
            }
        }

        var httpRequest: URLRequest {
            var request = URLRequest(url: baseURL.appendingPathComponent("summary"))
            request.httpMethod = "GET"
            return request
        }
    }
}
