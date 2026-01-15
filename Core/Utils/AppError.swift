//
//  AppError.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import Foundation

enum AppError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let msg): return msg
        }
    }
}
