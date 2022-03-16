//
//  NetworkingManager.swift
//  
//
//  Created by Ines Sakly on 16/3/2022.
//

import Foundation

public enum ManagerErrors: Error {
        case invalidResponse
        case invalidStatusCode(Int)
    }
public enum HttpMethod: String {
       case get
       case post
       var method: String { rawValue.uppercased() }
   }
public class NetworkingManager {
   public init(){}
   public  func request<T: Decodable>(fromURL url: URL, httpMethod: HttpMethod , completion: @escaping (Result<T, Error>) -> Void) {
        let completionOnMain: (Result<T, Error>) -> Void = { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
        var request = URLRequest(url: url)
               request.httpMethod = httpMethod.method

               let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                                  completionOnMain(.failure(error))
                                  return
                              }
                   guard let urlResponse = response as? HTTPURLResponse else { return completionOnMain(.failure(ManagerErrors.invalidResponse)) }
                               if !(200..<300).contains(urlResponse.statusCode) {
                                   return completionOnMain(.failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode)))
                               }
                   do {
                       if let data = data {
                           let users = try JSONDecoder().decode(T.self, from: data)
                           completionOnMain(.success(users))
                       }
                              } catch {
                                  debugPrint("Could not get the data. Reason: \(error.localizedDescription)")
                                  completionOnMain(.failure(error))
                              }
               }
        urlSession.resume()
    }
}
