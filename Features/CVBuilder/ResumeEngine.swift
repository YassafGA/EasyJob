import Foundation
import ZIPFoundation

final class ResumeEngine {

    /// Template docx + placeholder map -> yeni docx (Documents içine)
    func generateResume(
        templateURL: URL,
        data: [String: Any],
        profileImageData: Data? = nil,
        outputFileName: String = "Final_CV.docx"
    ) -> URL? {

        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: templateURL.path) else {
            print("❌ Template yok: \(templateURL.path)")
            return nil
        }

        let uniqueID = UUID().uuidString
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent("Resume_Build_\(uniqueID)")

        do {
            try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: templateURL, to: tempDirectory)

            // 1) Replace text placeholders in word/document.xml
            let documentXmlURL = tempDirectory.appendingPathComponent("word/document.xml")
            if fileManager.fileExists(atPath: documentXmlURL.path) {
                var xmlContent = try String(contentsOf: documentXmlURL, encoding: .utf8)
                xmlContent = replacePlaceholders(in: xmlContent, with: data)
                try xmlContent.write(to: documentXmlURL, atomically: true, encoding: .utf8)
            }

            // 2) Replace profile image if provided
            if let imgData = profileImageData {
                replaceProfileImage(in: tempDirectory, with: imgData)
            }

            // 3) Zip back to docx in Documents
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let outputURL = docs.appendingPathComponent("\(outputFileName.replacingOccurrences(of: ".docx", with: ""))_\(uniqueID).docx")

            if fileManager.fileExists(atPath: outputURL.path) {
                try fileManager.removeItem(at: outputURL)
            }

            try zipDirectoryContents(at: tempDirectory, to: outputURL)

            // 4) Clean temp
            try fileManager.removeItem(at: tempDirectory)

            return outputURL
        } catch {
            print("❌ ResumeEngine error: \(error)")
            return nil
        }
    }

    private func replaceProfileImage(in tempDirectory: URL, with imageData: Data) {
        let mediaDirectory = tempDirectory.appendingPathComponent("word/media")
        let fileManager = FileManager.default

        do {
            guard fileManager.fileExists(atPath: mediaDirectory.path) else { return }

            let files = try fileManager.contentsOfDirectory(at: mediaDirectory, includingPropertiesForKeys: nil)

            if let targetImage = files.first(where: { $0.lastPathComponent.hasPrefix("image1") }) {
                try? fileManager.removeItem(at: targetImage)
                try imageData.write(to: targetImage)
            }
        } catch {
            print("⚠️ Image replace warning: \(error)")
        }
    }

    private func zipDirectoryContents(at sourceURL: URL, to destinationURL: URL) throws {
        let fileManager = FileManager.default

        guard let archive = Archive(url: destinationURL, accessMode: .create) else {
            throw NSError(domain: "ResumeEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Archive oluşturulamadı"])
        }

        let realSourceURL = sourceURL.resolvingSymlinksInPath()
        let realSourcePath = realSourceURL.path
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey]

        guard let enumerator = fileManager.enumerator(at: sourceURL, includingPropertiesForKeys: resourceKeys, options: []) else {
            return
        }

        for case let fileURL as URL in enumerator {
            let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys))
            if resourceValues?.isDirectory == true { continue }

            if fileURL.lastPathComponent == ".DS_Store" { continue }
            if fileURL.path.contains("__MACOSX") { continue }

            let realFileURL = fileURL.resolvingSymlinksInPath()
            let realFilePath = realFileURL.path

            if realFilePath.hasPrefix(realSourcePath) {
                var relativePath = realFilePath.replacingOccurrences(of: realSourcePath, with: "")
                if relativePath.hasPrefix("/") { relativePath.removeFirst() }
                try archive.addEntry(with: relativePath, fileURL: realFileURL)
            }
        }
    }

    private func cleanTextForXML(text: String) -> String {
        var clean = text
        clean = clean.replacingOccurrences(of: "&", with: "&amp;")
        clean = clean.replacingOccurrences(of: "<", with: "&lt;")
        clean = clean.replacingOccurrences(of: ">", with: "&gt;")
        clean = clean.replacingOccurrences(of: "\"", with: "&quot;")
        clean = clean.replacingOccurrences(of: "\n", with: "<w:br/>")
        return clean
    }

    private func replacePlaceholders(in xml: String, with data: [String: Any]) -> String {
        var result = xml
        for (key, value) in data {
            result = replacePlaceholder(in: result, key: key, value: "\(value)")
        }
        return result
    }

    private func replacePlaceholder(in xml: String, key: String, value: String) -> String {
        let cleanValue = cleanTextForXML(text: value)
        let glue = "(?:<[^>]+>|\\s)*"
        var pattern = "\\{\\{"
        for ch in key {
            pattern += glue + NSRegularExpression.escapedPattern(for: String(ch))
        }
        pattern += glue + "\\}\\}"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return xml
        }
        let range = NSRange(xml.startIndex..<xml.endIndex, in: xml)
        return regex.stringByReplacingMatches(in: xml, options: [], range: range, withTemplate: cleanValue)
    }
}
