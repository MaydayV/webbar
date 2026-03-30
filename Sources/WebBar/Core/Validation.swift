import Foundation

enum LinkValidationError: LocalizedError, Equatable {
    case emptyURL
    case malformedURL
    case missingScheme

    var errorDescription: String? {
        switch self {
        case .emptyURL:
            return "网址不能为空"
        case .malformedURL:
            return "网址格式不正确"
        case .missingScheme:
            return "网址必须包含 scheme，例如 https:// 或 mailto:"
        }
    }
}

struct LinkValidator {
    func validateURLString(_ raw: String) throws -> URL {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw LinkValidationError.emptyURL
        }
        guard let url = URL(string: trimmed) else {
            throw LinkValidationError.malformedURL
        }
        guard let scheme = url.scheme, scheme.isEmpty == false else {
            throw LinkValidationError.missingScheme
        }
        return url
    }

    func validateCreate(urlString: String, currentCount: Int) throws -> URL {
        return try validateURLString(urlString)
    }

    func validateUpdate(urlString: String) throws -> URL {
        try validateURLString(urlString)
    }
}
