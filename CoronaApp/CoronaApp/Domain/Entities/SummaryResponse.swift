//
//  SummaryResponse.swift
//  CoronaApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import Foundation

struct SummaryResponse: Codable {
    let global: Global
    let countries: [Country]

    enum CodingKeys: String, CodingKey {
        case global = "Global"
        case countries = "Countries"
    }

    struct Global: Codable {
        let newConfirmed: Int
        let totalConfirmed: Int
        let newDeaths: Int
        let totalDeaths: Int
        let newRecovered: Int
        let totalRecovered: Int

        enum CodingKeys: String, CodingKey {
            case newConfirmed = "NewConfirmed"
            case totalConfirmed = "TotalConfirmed"
            case newDeaths = "NewDeaths"
            case totalDeaths = "TotalDeaths"
            case newRecovered = "NewRecovered"
            case totalRecovered = "TotalRecovered"
        }
    }

    struct Country: Codable {
        let country: String
        let countryCode: String
        let slug: String

        let newConfirmed: Int
        let totalConfirmed: Int
        let newDeaths: Int
        let totalDeaths: Int
        let newRecovered: Int
        let totalRecovered: Int

        enum CodingKeys: String, CodingKey {
            case country = "Country"
            case countryCode = "CountryCode"
            case slug = "Slug"
            case newConfirmed = "NewConfirmed"
            case totalConfirmed = "TotalConfirmed"
            case newDeaths = "NewDeaths"
            case totalDeaths = "TotalDeaths"
            case newRecovered = "NewRecovered"
            case totalRecovered = "TotalRecovered"
        }
    }
}
