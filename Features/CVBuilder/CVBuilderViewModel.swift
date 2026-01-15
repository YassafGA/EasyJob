import Foundation

@MainActor
final class CVBuilderViewModel: ObservableObject {
    @Published var isWorking = false
    @Published var statusText: String?
    @Published var errorMessage: String?
    @Published var generatedDocxURL: URL?

    private let jsonStore = CVPlaceholderJSONStore()
    private let templateEngine = DocxTemplateEngine()

    /// Tek akış:
    /// DB -> JSON -> placeholder map -> DOCX
    func buildCV(templateFileName: String = "cv_template", templateExt: String = "docx", profileImageData: Data? = nil) async {
        isWorking = true
        statusText = "Başlatılıyor..."
        errorMessage = nil
        generatedDocxURL = nil
        defer { isWorking = false }

        do {
            statusText = "JSON oluşturuluyor..."
            let jsonURL = try await jsonStore.exportPlaceholdersJSON(fileName: "cv_placeholders.json")

            statusText = "JSON okunuyor..."
            let placeholders = try loadPlaceholderMap(from: jsonURL)

            statusText = "DOCX üretiliyor..."
            let docxURL = try templateEngine.generateDocx(
                templateFileName: templateFileName,
                templateExt: templateExt,
                placeholders: placeholders,
                profileImageData: profileImageData,
                outputFileName: "EasyJob_CV.docx"
            )

            generatedDocxURL = docxURL
            statusText = "CV hazır ✅"
        } catch {
            errorMessage = error.localizedDescription
            statusText = nil
        }
    }

    private func loadPlaceholderMap(from url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        return (obj as? [String: Any]) ?? [:]
    }
}
