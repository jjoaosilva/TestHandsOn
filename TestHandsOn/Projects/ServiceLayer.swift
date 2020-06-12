//
//  ServiceLayer.swift
//  Medium
//
//  Created by Gabriela Bezerra on 07/06/20.
//

import Foundation

struct ServiceLayer {
    
    static func request(router: Router, completion: @escaping (Result<Data?, ServiceError>) -> ()) {
        
        guard let request = router.urlRequest else {
            completion(.failure(ServiceError.malformedURLRequest(url: router.url?.absoluteString ?? "nil")))
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(description: error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            switch response.statusCode {
            case 200, 201:
                completion(.success(data))
            case 400:
                completion(.failure(.badRequest))
            case 404:
                completion(.failure(.notFound))
            default:
                completion(.failure(.unknownError(statusCode: response.statusCode)))
            }
        }
        
        dataTask.resume()
    }
    
    
    static func requestWithInjection(router: Router, session: URLSession = URLSession.shared, completion: @escaping (Result<Data?, ServiceError>) -> ()) {
        
        guard let request = router.urlRequest else {
            completion(.failure(ServiceError.malformedURLRequest(url: router.url?.absoluteString ?? "nil")))
            return
        }
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(description: error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed(description: "no response")))
                return
            }
            
            switch response.statusCode {
            case 200, 201:
                completion(.success(data))
            case 400:
                completion(.failure(.badRequest))
            case 404:
                completion(.failure(.notFound))
            default:
                completion(.failure(.unknownError(statusCode: response.statusCode)))
            }
        }
        
        dataTask.resume()
    }
}
