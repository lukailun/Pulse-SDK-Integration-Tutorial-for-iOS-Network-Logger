import PulseCore
import UIKit

class NetworkService: NSObject {
    private let baseURLString = "https://api.themoviedb.org"
    private let imageBaseURLString = "https://image.tmdb.org"

    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private let logger = NetworkLogger()
    var searchCompletion: ((Result<[Movie], NetworkError>) -> Void)?

    @discardableResult
    func search(for searchTerm: String) -> URLSessionDataTask? {
        guard let url = try? url(for: searchTerm) else {
            searchCompletion?(.failure(NetworkError.invalidURL))
            return nil
        }

        let task = urlSession.dataTask(with: url)
        task.delegate = self
        task.resume()

        return task
    }

    func downloadImage(for imageType: ImageType, at path: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let url = try? url(for: imageType, at: path) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let task = urlSession.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(NetworkError.invalidResponseType))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data
            else {
                completion(.failure(NetworkError.invalidResponseType))
                return
            }

            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidParse))
                return
            }

            completion(.success(image))
        }

        task.resume()
    }

    private func url(for imageType: ImageType, at path: String) throws -> URL {
        let imagePathParam = imageType.pathParameter()
        guard let baseURL = URL(string: imageBaseURLString),
              var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.invalidURL
        }

        urlComponents.path = "/t/p/\(imagePathParam)\(path)"

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: APIKey.value),
        ]

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        return url
    }

    private func url(for searchTerm: String) throws -> URL {
        guard let baseURL = URL(string: baseURLString),
              var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.invalidURL
        }

        urlComponents.path = "/3/search/movie"

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: APIKey.value),
            URLQueryItem(name: "language", value: "en-us"),
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "page", value: "1"),
        ]

        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }

        return url
    }
}

extension NetworkService: URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(
        _: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        logger.logDataTask(dataTask, didReceive: response)
        if let response = response as? HTTPURLResponse,
           response.statusCode != 200
        {
            searchCompletion?(.failure(.invalidResponseType))
        }
        completionHandler(.allow)
    }

    func urlSession(
        _: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        logger.logTask(task, didCompleteWithError: error)
    }

    func urlSession(
        _: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        logger.logTask(task, didFinishCollecting: metrics)
    }

    func urlSession(
        _: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        logger.logDataTask(dataTask, didReceive: data)
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let movieResponse = try decoder.decode(MovieResponse.self, from: data)
            searchCompletion?(.success(movieResponse.list))
        } catch {
            searchCompletion?(.failure(NetworkError.invalidParse))
        }
    }
}
