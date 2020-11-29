//
//  CoronaAppApp.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import SwiftUI

@main
struct CoronaAppApp: App {
    var container: Container = .default

    var body: some Scene {
        WindowGroup {
            TabView {
                CountrySearchView()
                    .environmentObject(
                        container.resolve() as AnyViewModel<CountrySearch>
                    )
                NavigationView {
                    HStack {}.navigationTitle("TODO")
                }
                .tabItem { Text("TODO") }
            }
            .environmentObject(container)
        }
    }
}

private extension Container {
    static var `default`: Container {
        let container = Container()
        createDependencies(container)
        __InjectedContainerProvider.container = container
        return container
    }
}

private func createDependencies(_ container: Container) {
    container.register { _ -> HTTPClientProtocol in
        HTTPClient()
    }

    container.register { _ -> CoronaAPIServiceProtocol in
        CoronaAPIService()
    }

    // MARK: - Modules
    container.register { _ -> CountrySearchViewModelProtocol in
        CountrySearch.ViewModel()
    }

    container.register { container -> AnyViewModel<CountrySearch> in
        let viewModel: CountrySearchViewModelProtocol = container.resolve()
        return AnyViewModel(
            input: { action in viewModel.handleInput(action) },
            output: viewModel.output
        )
    }
}
