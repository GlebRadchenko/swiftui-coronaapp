//
//  CountrySearchView.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import SwiftUI

struct CountrySearchView: View {
    @EnvironmentObject var viewModel: AnyViewModel<CountrySearch>

    @State private var searchBarText: String = ""
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBar(
                        placeholder: "Search for a country..",
                        text: .init(
                            get: { searchBarText },
                            set: { newValue in
                                searchBarText = newValue
                                viewModel.handleInput(.searchTextChanged(newValue))
                            }
                        ),
                        isEditing: $isEditing
                    )

                    switch viewModel.output {
                    case .empty:
                        VStack {
                            Text("No Results")
                            LoadingSpinner()
                                .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        }
                    case .loading:
                        LoadingSpinner()
                            .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    case let .loaded(countries):
                        ForEach(countries, id: \.country) { country in
                            VStack(spacing: 4) {
                                HStack(alignment: .center, spacing: 8) {
                                    Text(country.country)
                                    Text(country.countryCode)
                                    Text(country.slug)
                                    Spacer()
                                }
                                HStack {
                                    Text("Total deaths: \(country.totalDeaths)")
                                    Spacer()
                                }
                            }
                            Divider()
                        }
                        .padding()
                    }
                }
            }
            .onAppear { viewModel.handleInput(.viewLoaded) }
            .navigationBarHidden(isEditing)
            .navigationTitle("Search")
        }
        .transition(.move(edge: .top))
        .tabItem { Text("Search") }
    }
}

struct CountrySearchView_Previews: PreviewProvider {
    static var previews: some View {
        CountrySearchView()
            .environmentObject(
                AnyViewModel<CountrySearch>.just(output: .loading)
            )
    }
}
