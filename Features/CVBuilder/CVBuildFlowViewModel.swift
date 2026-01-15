//
//  CVBuildFlowViewModel.swift
//  EasyJob
//
//  Created by MAC on 26.12.2025.
//


import Foundation
import Supabase

@MainActor
final class CVBuildFlowViewModel: ObservableObject {
    @Published var isWorking = false
    @Published var statusText: String?
    @Published var errorMessage: String?
    @Published var generatedDocxURL: URL?

    private let jsonStore = CVPlaceholderJSONStore()
    private let resumeEngine = ResumeEngine()

    /// 1) DB -> JSON
    /// 2) JSON -> placeholder map
    /// 3) template.docx -> DOCX
    func buildCV(templateFileName: String = "cv_template", templateExt: String = "docx", profileImageData: Data? = nil) async {
        isWorking = true
        errorMessage = nil
        generatedDocxURL = nil
        statusText = "Veriler hazırlanıyor..."
        defer { isWorking = false }

        do {
            // A) JSON üret
            statusText = "JSON oluşturuluyor..."
            let jsonURL = try await jsonStore.exportPlaceholdersJSON(fileName: "cv_placeholders.json")

            // B) JSON oku -> map
            statusText = "JSON okunuyor..."
            let map = try loadPlaceholderMap(from: jsonURL)

            // C) Template URL (Bundle)
            statusText = "Template yükleniyor..."
            guard let templateURL = Bundle.main.url(forResource: templateFileName, withExtension: templateExt) else {
                throw NSError(domain: "CVBuild", code: 404, userInfo: [NSLocalizedDescriptionKey: "Template bulunamadı. \(templateFileName).\(templateExt) dosyasını projeye ekleyip Target Membership işaretle."])
            }

            // D) DOCX üret
            statusText = "DOCX üretiliyor..."
            let out = resumeEngine.generateResume(
                templateURL: templateURL,
                data: map,
                profileImageData: profileImageData,
                outputFileName: "EasyJob_CV.docx"
            )

            guard let out else {
                throw NSError(domain: "CVBuild", code: 500, userInfo: [NSLocalizedDescriptionKey: "DOCX üretilemedi (ResumeEngine nil döndü)."])
            }

            generatedDocxURL = out
            statusText = "CV hazır ✅"
        } catch {
            errorMessage = error.localizedDescription
            statusText = nil
        }
    }

    private func loadPlaceholderMap(from url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = obj as? [String: Any] else {
            return [:]
        }
        return dict
    }
}
