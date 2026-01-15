import Foundation

final class DocxTemplateEngine {

    private let resumeEngine = ResumeEngine()

    /// Template docx + placeholder map -> generated docx URL (Documents)
    func generateDocx(
        templateFileName: String,
        templateExt: String = "docx",
        placeholders: [String: Any],
        profileImageData: Data? = nil,
        outputFileName: String = "EasyJob_CV.docx"
    ) throws -> URL {

        // ✅ 1) Bundle URL opsiyonel gelir, unwrap şart
        guard let templateURL = Bundle.main.url(forResource: templateFileName, withExtension: templateExt) else {
            throw NSError(
                domain: "DocxTemplateEngine",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Template bulunamadı: \(templateFileName).\(templateExt). Dosyayı projeye ekleyip Target Membership işaretle."]
            )
        }

        // ✅ 2) ResumeEngine parametre label: data:
        guard let outURL = resumeEngine.generateResume(
            templateURL: templateURL,
            data: placeholders,
            profileImageData: profileImageData,
            outputFileName: outputFileName
        ) else {
            throw NSError(
                domain: "DocxTemplateEngine",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "DOCX üretilemedi (ResumeEngine nil döndü)."]
            )
        }

        return outURL
    }
}
