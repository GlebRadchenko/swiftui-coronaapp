//
//  AnyViewModel.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import Combine
import SwiftUI

protocol ModuleNamespace {
    associatedtype Output
    associatedtype Input
}

protocol DefaultRepresentable {
    static var `defaultValue`: Self { get }
}

class AnyViewModel<Namespace: ModuleNamespace>: ObservableObject {
    typealias Output = Namespace.Output
    typealias Input = Namespace.Input

    @Published var output: Output

    private let disposeBag = DisposeBag()

    init(input: @escaping (Input) -> Void, output: AnyPublisher<Output, Never>, defaultOutput: Output) {
        self.inputBlock = input
        self.output = defaultOutput
        output
            .receive(on: DispatchQueue.main)
            .assign(to: \.output, on: self)
            .disposed(by: disposeBag)
    }

    init(
        input: @escaping (Input) -> Void,
        output: AnyPublisher<Output, Never>,
        defaultOutput: Output = .defaultValue
    ) where Output: DefaultRepresentable {
        self.inputBlock = input
        self.output = defaultOutput

        output
            .receive(on: DispatchQueue.main)
            .assign(to: \.output, on: self)
            .disposed(by: disposeBag)
    }

    private let inputBlock: (Input) -> Void
    func handleInput(_ input: Input) {
        inputBlock(input)
    }

    static func just(output: Output) -> AnyViewModel<Namespace> {
        .init(input: { _ in }, output: Just(output).eraseToAnyPublisher(), defaultOutput: output)
    }
}
