import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
            let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            let task = dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200..<300 ~= statusCode {
                        fulfillCompletionOnTheMainThread(.success(data))
                    } else {
                        print("Error: httpStatusCode \(NetworkError.httpStatusCode(statusCode))")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                        print("[URLSession.data]: [Invalid HTTP Status Code:\(NetworkError.httpStatusCode(statusCode))]")
                    }
                } else if let error = error {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                    print("[URLSession.data]: [URLRequest error:\(error.localizedDescription)]")
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                    print("[URLSession.data]: [URLSession error:\(NetworkError.urlSessionError)]")
                }
            })
            return task
        }
    
        func objectTask<T: Decodable>(
            for request: URLRequest,
            completion: @escaping (Result<T, Error>) -> Void
        ) -> URLSessionTask {
            let decoder = JSONDecoder()
            let task = data(for: request) { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    do {
                        let response = try decoder.decode(T.self, from: data)
                        completion (.success(response))
                    } catch {
                        completion (.failure(error))
                        print("[URLSession.objectTask]: [Data not decode]:[Error:\(error.localizedDescription)] Data: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                case .failure(let error):
                    completion (.failure(error))
                    print("[URLSession.objectTask]:[Not data available]:[Error:\(error.localizedDescription)]")
                }
            }
            return task
        }
    }

