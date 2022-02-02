//
//  StravaApi.swift
//  BikeComputer
//
//  Created by Allen Liang on 11/19/21.
//

import Foundation
import SwiftUI
import Alamofire

enum StravaKeys: String {
    case accessToken = "strava_access_token"
    case refreshToken = "strava_refresh_token"
    case expiresAt = "strava_expires_at"
    case authState = "strava_auth_state"
    case shareActivity = "strava_share_activity"
}

protocol StravaApiProtocol {
    func requestAccessToken(code: String, completion: @escaping (Result<Bool, Error>) -> ())
    func refreshAccessTokens(completion: @escaping (Result<Bool, Error>) -> ())
    func uploadActivity(gpxURL: URL, completion: @escaping (Result<Bool, AFError>) -> ())
}

class StravaAPI: StravaApiProtocol {
    private let session: Session
    
    init() {
        self.session = Session(interceptor: StravaRequestInteceptor())
        fetchAuthFromUserDefaults()
    }
    
    static let shared = StravaAPI()
    private(set) var accessToken = ""
    private(set) var refreshToken = ""
    private(set) var tokenExpiresAt = 0
    
    func requestAccessToken(code: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.strava.com"
        urlComponents.path = "/api/v3/oauth/token"
        urlComponents.queryItems = [URLQueryItem(name: "client_id", value: "\(StravaConfig.clientId)"),
                                    URLQueryItem(name: "client_secret", value: "\(StravaConfig.clientSecret)"),
                                    URLQueryItem(name: "code", value: code),
                                    URLQueryItem(name: "grant_type", value: "authorization_code")]
        AF.request(urlComponents, method: .post).validate().response { response in
            switch response.result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                if let responseData = response.data {
                    do {
                        let auth = try JSONDecoder().decode(StravaAuth.self, from: responseData)
                        self.setTokens(auth: auth)
                    } catch {
                        //handle error
                    }
                }
                completion(.success(true))
            }
        }
    }
    
    func refreshAccessTokens(completion: @escaping (Result<Bool, Error>) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.strava.com"
        urlComponents.path = "/api/v3/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"), // TODO: YDNT
            URLQueryItem(name: "client_id", value: "\(StravaConfig.clientId)"),
            URLQueryItem(name: "client_secret", value: "\(StravaConfig.clientSecret)"),
            URLQueryItem(name: "refresh_token", value: self.refreshToken)]
        
        AF.request(urlComponents, method: .post).validate().response { response in
            switch response.result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(true))
            }
        }
    }
    
    func uploadActivity(gpxURL: URL, completion: @escaping (Result<Bool, AFError>) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.strava.com"
        urlComponents.path = "/api/v3/uploads"
        urlComponents.queryItems = [URLQueryItem(name: "data_type", value: "gpx")]
        
        session.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(gpxURL, withName: "file")
        }, to: urlComponents)
            .validate()
            .response { response in // TODO: handle status codes
                switch response.result {
                case .failure(let afError):
                    completion(.failure(afError))
                    return
                case .success(_):
                    completion(.success(true))
                    return
                }
                completion(.failure(AFError.explicitlyCancelled))
            }
    }
    
    private func setTokens(auth: StravaAuth) {
        UserDefaults.standard.set(auth.access_token, forKey: StravaKeys.accessToken.rawValue)
        UserDefaults.standard.set(auth.refresh_token, forKey: StravaKeys.refreshToken.rawValue)
        UserDefaults.standard.set(auth.expires_at, forKey: StravaKeys.expiresAt.rawValue)
        self.accessToken = auth.access_token
        self.refreshToken = auth.refresh_token
        self.tokenExpiresAt = auth.expires_at
    }
    
    private func fetchAuthFromUserDefaults() {
        self.accessToken = UserDefaults.standard.string(forKey: StravaKeys.accessToken.rawValue) ?? ""
        self.refreshToken = UserDefaults.standard.string(forKey: StravaKeys.refreshToken.rawValue) ?? ""
        self.tokenExpiresAt = UserDefaults.standard.integer(forKey: StravaKeys.expiresAt.rawValue)
    }
}




