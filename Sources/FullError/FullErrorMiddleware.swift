import Vapor

/// Captures all errors and transforms them into an internal server error HTTP response.
public struct FullErrorMiddleware: AsyncMiddleware {
    // MARK: - Init
    public init() { }
    
    // MARK: - Methods
    /// See `Middleware`.
    public func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: req)
        } catch {
            return await self.body(req: req, error: error)
        }
    }

    /// Error-handling closure.
    private func body(req: Request, error: Error) async -> Response {

        req.application.logger.report(error: error)

        // variables to determine
        let code: String
        let headers: HTTPHeaders
        let reason: String
        let status: HTTPResponseStatus
        lazy var failures: [ValidationFailure] = []

        // inspect the error type
        switch error {
        case let custom as CodeError:
            code = custom.code
            headers = custom.headers
            reason = custom.reason
            status = custom.status
        case let validation as Vapor.ValidationsError:
            
            for failure in validation.failures {
                if let description = failure.customFailureDescription {
                    let items = description.split(separator: ":").map { String($0) }
                    failures.append(ValidationFailure(
                        field: failure.key.stringValue,
                        code: items[0],
                        reason: items[1]))
                } else {
                    failures.append(ValidationFailure(
                        field: failure.key.stringValue,
                        code: "",
                        reason: failure.result.failureDescription ?? ""))
                }
            }
            code = "validationError"
            headers = [:]
            reason = "Validation errors occurs"
            status = .badRequest
        case let abort as AbortError:
            code = "abortError"
            headers = abort.headers
            reason = abort.reason
            status = abort.status
        default:
            code = "internalApplicationError"
            headers = [:]
            reason = "Something went wrong"
            status = .internalServerError
        }

        // Attempt to serialize the error to json.
        do {
            let errorResponse = ErrorResponse(code: code, reason: reason, failures: failures)
            let body = try Response.Body(data: JSONEncoder().encode(errorResponse))
            let response = Response(status: status, headers: headers, body: body)
            response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")

            return response
        } catch {
            let body = Response.Body(string: "Oops: \(error)")
            let response = Response(status: status, headers: headers, body: body)
            response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            
            return response
        }
    }
}

