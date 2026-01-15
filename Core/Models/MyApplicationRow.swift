//
//  MyApplicationRow.swift
//  EasyJob
//
//  Created by MAC on 25.12.2025.
//


import Foundation

struct MyApplicationRow: Codable, Identifiable {
    let id: UUID
    let candidate_id: UUID
    let job_id: UUID
    let status: String
    let cover_letter: String?
    let created_at: Date?

    let job_title: String
    let job_location: String
    let job_work_model: String?
    let job_seniority: String?
}
