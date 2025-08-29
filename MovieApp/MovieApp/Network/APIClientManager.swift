//
//  APIClientManager.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case noInternet
    case unknown
}

struct EmptyBody: Encodable {}

class APIClient {
    static let shared = APIClient()
    private init() {}
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession.shared
    
    // MARK: - Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkN2ZmZjQzODMzNmM1YmVhNzg0MDhiMmE5MTRhOWIwOSIsIm5iZiI6MTY0NDM4Mjc5Ni4xNjMsInN1YiI6IjYyMDM0YTRjMmYzYjE3MDA2YTM5ODFkNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.81HikrrA6_EraBuKihVq4kX2ljlgNPMZI0W8aubJNcU", forHTTPHeaderField: "Authorization")
        
        print("Request URL: \(request.url?.absoluteString ?? "")")
        print("HTTP Method: \(method)")
     //   print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body: \(body ?? EmptyBody())")
        
        if method == "POST", let body = body {
            printBody(body)
            do {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.requestFailed(error)))
                return
            }
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.noInternet))
                    return
                }
                completion(.failure(.requestFailed(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode,
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            print("STATUS CODE: \(httpResponse.statusCode)")
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }
    func printBody<T: Encodable>(_ body: T?) {
        guard let body = body else {
            print("Request body is nil")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // readable & deterministic
            let data = try encoder.encode(body)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Request Body JSON:\n\(jsonString)")
            } else {
                print("Failed to convert body to string")
            }
        } catch {
            print("Failed to encode body: \(error)")
        }
    }
    


}
