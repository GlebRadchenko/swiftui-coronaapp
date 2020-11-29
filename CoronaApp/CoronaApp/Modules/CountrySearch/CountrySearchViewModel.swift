//
//  CountrySearchViewModel.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation
import Combine

enum CountrySearch: ModuleNamespace {
    typealias Output = State
    typealias Input = Action

    enum State: DefaultRepresentable {
        static var defaultValue: State = .empty

        case empty
        case loading
        case loaded([SummaryResponse.Country])
    }

    enum Action {
        case viewLoaded
        case searchTextChanged(String)
    }
}

protocol CountrySearchViewModelProtocol {
    var output: AnyPublisher<CountrySearch.State, Never> { get }
    func handleInput(_ input: CountrySearch.Action)
}

extension CountrySearch {
    class ViewModel: CountrySearchViewModelProtocol {
        @Injected private var service: CoronaAPIServiceProtocol

        private let outputSubject = CurrentValueSubject<State, Never>(.empty)
        lazy var output: AnyPublisher<State, Never> = outputSubject.eraseToAnyPublisher()

        private let searchTextSubject = PassthroughSubject<String, Never>()

        let disposeBag = DisposeBag()

        func handleInput(_ input: Action) {
            switch input {
            case .viewLoaded:
                configureSubscriptions()
            case let .searchTextChanged(searchText):
                searchTextSubject.send(searchText)
            }
        }

        // MARK: - Private
        private func configureSubscriptions() {
            disposeBag.insert { [outputSubject, service] in
                searchTextSubject
                    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
                    .flatMap { searchText in
                        service.summary()
                            .ignoreError()
                            .map(\.countries)
                            .map { countries in
                                searchText.isEmpty
                                    ? countries
                                    : countries.filter { $0.has(text: searchText) }
                            }
                    }
                    .sink { countries in
                        outputSubject.send(countries.isEmpty ? .empty : .loaded(countries))
                    }
            }
        }
    }
}

private extension SummaryResponse.Country {
    func has(text: String) -> Bool {
        let text = text.lowercased()
        return country.lowercased().contains(text)
            || countryCode.lowercased().contains(text)
            || slug.lowercased().contains(text)
    }
}
