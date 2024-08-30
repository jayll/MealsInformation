//
//  NetworkError.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/28/24.
//

import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case badURL
    case badResponse(statusCode: Int)
    case url(URLError?)
    case parsing(DecodingError?)
    case unknown

    var localizedDescription: String {
        switch self {
        case .badURL, .parsing, .unknown:
            return "Sorry, something went wrong."
        case .badResponse:
            return "Sorry, the connection to our server failed."
        case .url(let error):
            return error?.localizedDescription ?? "Something went wrong."
        }
    }

    var description: String {
        switch self {
        case .unknown: return "Unknown error"
        case .badURL: return "Invalid URL"
        case .url(let error):
            return error?.localizedDescription ?? "Url session error"
        case .parsing(let error):
            return "Parsing error \(error?.localizedDescription ?? "")"
        case .badResponse(statusCode: let statusCode):
            return "Bad response with status code \(statusCode)"
        }
    }
}
