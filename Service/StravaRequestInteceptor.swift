//
//  StravaRequestInteceptor.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/27/21.
//

import Foundation
import Alamofire

class StravaRequestInteceptor: RequestInterceptor {
    let retryLimit = 2
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        request.setValue("Bearer \(StravaAPI.shared.accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if request.retryCount > 2 {
            completion(.doNotRetry)
        }
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            StravaAPI.shared.refreshAccessTokens { result in
                switch result {
                case .failure(_):
                    completion(.doNotRetry)
                case .success(_):
                    completion(.retry)
                }
            }
        } else {
            completion(.doNotRetry)
        }
    }
}
