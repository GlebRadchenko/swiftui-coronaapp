//
//  Publisher.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import Combine

extension Publisher {
    var asVoidPublisher: AnyPublisher<Void, Failure> {
        map { _ in }.eraseToAnyPublisher()
    }

    func unwrap<Result>() -> AnyPublisher<Result, Failure> where Output == Result? {
        compactMap { $0 }.eraseToAnyPublisher()
    }

    func optionalize() -> AnyPublisher<Output?, Failure> {
        map { $0 }.eraseToAnyPublisher()
    }

    func ignoreError() -> AnyPublisher<Output, Never> {
        optionalize().replaceError(with: nil).unwrap()
    }

    func subscribe() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
