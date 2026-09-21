import Foundation
import UIKit

struct AIAnalysis: Codable {
    var mealName: String
    var foods: [FoodItem]
    var estimatedCalories: Int?
    var protein: Double?
    var fiber: Double?
    var note: String?
}

enum AIServiceError: Error {
    case badResponse
    case invalidData
}

struct AIService {
    // Set this to your HTTPS backend before running on a device.
    // Keep your OpenAI API key on the server, never inside the iPhone app.
    static let endpoint = URL(string: "https://YOUR-BACKEND.example.com/analyze")!

    static func analyze(image: UIImage) async throws -> AIAnalysis {
        guard let imageData = image.jpegData(compressionQuality: 0.82) else {
            throw AIServiceError.invalidData
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"image\"; filename=\"meal.jpg\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
        body.append(imageData)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AIServiceError.badResponse
        }
        return try JSONDecoder().decode(AIAnalysis.self, from: data)
    }
}
