//
//  CardViewModel.swift
//  M19
//
//  Created by Александра Угольнова on 02.10.2023.
//

import Foundation

struct MovieDetail: Codable {
    let nameRu: String
    let nameOriginal: String
    let posterUrl: String
    let ratingKinopoisk: Double
    let ratingImdb: Double
    let year: Int
    let filmLength: Int
    let description: String
}
