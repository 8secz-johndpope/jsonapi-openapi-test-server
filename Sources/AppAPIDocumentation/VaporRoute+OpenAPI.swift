//
//  VaporRoute+OpenAPIEncodedNodeType.swift
//  AppAPIDocumentation
//
//  Created by Mathew Polzin on 10/19/19.
//

import Foundation
import OpenAPIKit
import Vapor
import App

extension EventLoopFuture: OpenAPIEncodedNodeType where Value: OpenAPIEncodedNodeType {
    public static func openAPINode(using encoder: JSONEncoder) throws -> JSONSchema {
        return try Value.openAPINode(using: encoder)
    }
}

protocol _Wrapper {
    static var wrappedType: Any.Type { get }
}

extension Optional: _Wrapper {
    static var wrappedType: Any.Type {
        return Wrapped.self
    }
}

extension AbstractRouteContext {
    static func openAPIResponses(using encoder: JSONEncoder) throws -> OpenAPI.Response.Map {

        let responseTuples = try responseBodyTuples
            .compactMap { responseTuple -> (OpenAPI.Response.StatusCode, OpenAPI.Response)? in

                let statusCode = OpenAPI.Response.StatusCode.status(
                    code: responseTuple.statusCode
                )

                let schema = try (responseTuple.responseBodyType as? OpenAPIEncodedNodeType.Type)?.openAPINode(using: encoder)

                return schema
                    .map {
                        OpenAPI.Response(
                            description: HTTPStatus.init(statusCode: responseTuple.statusCode).reasonPhrase,
                            content: [
                                .json: .init(schema: .init($0))
                            ]
                        )
                }.map { (statusCode, $0) }
        }

        return Dictionary(
            responseTuples,
            uniquingKeysWith: { $1 }
        ).mapValues { .init($0) }
    }
}

extension Vapor.Route {
    func openAPIPathOperationConstructor(using encoder: JSONEncoder) throws -> PathOperationConstructor {
        let pathComponents = try OpenAPI.PathComponents(
            path.map { try $0.openAPIPathComponent() }
        )

        let verb = try method.openAPIVerb()

        let requestBodyType = (requestType as? OpenAPIEncodedNodeType.Type)
            ?? ((requestType as? _Wrapper.Type)?.wrappedType as? OpenAPIEncodedNodeType.Type)

        let requestBody = try requestBodyType
            .map { requestType -> OpenAPI.Request in
                let schema = try requestType.openAPINode(using: encoder)

                return OpenAPI.Request(
                    content: [
                        .json: .init(schema: .init(schema))
                    ]
                )
        }

        let responses = try openAPIResponses(from: responseType, using: encoder)

        let pathParameters = path.compactMap { $0.openAPIPathParameter }

        return { context in

            let operation = OpenAPI.PathItem.Operation(
                tags: context.tags,
                summary: context.summary,
                description: context.description,
                externalDocs: nil,
                operationId: nil,
                parameters: pathParameters.map { .init($0) },
                requestBody: requestBody,
                responses: responses,
                servers: []
            )

            return (
                path: pathComponents,
                verb: verb,
                operation: operation
            )
        }
    }

    func openAPIPathOperation(using encoder: JSONEncoder) throws -> (path: OpenAPI.PathComponents, verb: OpenAPI.HttpVerb, operation: OpenAPI.PathItem.Operation) {
        let operation = try openAPIPathOperationConstructor(using: encoder)

        let summary = userInfo["openapi:summary"] as? String
        let description = userInfo["description"] as? String
        let tags = userInfo["openapi:tags"] as? [String]

        return operation(
            (
                summary: summary,
                description: description,
                tags: tags
            )
        )
    }

    private func openAPIResponses(from responseType: Any.Type, using encoder: JSONEncoder) throws -> OpenAPI.Response.Map {

        if let responseBodyType = responseType as? AbstractRouteContext.Type {
            return try responseBodyType.openAPIResponses(using: encoder)
        }

        let responseBodyType = (responseType as? OpenAPIEncodedNodeType.Type)
            ?? ((responseType as? _Wrapper.Type)?.wrappedType as? OpenAPIEncodedNodeType.Type)

        let successResponse = try responseBodyType
            .map { responseType -> OpenAPI.Response in
                let schema = try responseType.openAPINode(using: encoder)

                return .init(
                    description: "Success",
                    content: [
                        .json: .init(schema: .init(schema))
                    ]
                )
        }

        let responseTuples = [
            successResponse.map{ (OpenAPI.Response.StatusCode(200), $0) }
            ].compactMap { $0 }

        return Dictionary(
            responseTuples,
            uniquingKeysWith: { $1 }
        ).mapValues { .init($0) }
    }
}

typealias PartialPathOperationContext = (
    summary: String?,
    description: String?,
    tags: [String]?
)

typealias PathOperationConstructor = (PartialPathOperationContext) -> (path: OpenAPI.PathComponents, verb: OpenAPI.HttpVerb, operation: OpenAPI.PathItem.Operation)

extension HTTPMethod {
    internal func openAPIVerb() throws -> OpenAPI.HttpVerb {
        switch self {
        case .GET:
            return .get
        case .PUT:
            return .put
        case .POST:
            return .post
        case .DELETE:
            return .delete
        case .OPTIONS:
            return .options
        case .HEAD:
            return .head
        case .PATCH:
            return .patch
        case .TRACE:
            return .trace
        default:
            throw OpenAPIHTTPMethodError.unsupportedHttpMethod(String(describing: self))
        }
    }

    enum OpenAPIHTTPMethodError: Swift.Error {
        case unsupportedHttpMethod(String)
    }
}

extension Vapor.PathComponent {
    internal func openAPIPathComponent() throws -> String {
        switch self {
        case .constant(let val):
            return val
        case .parameter(let val):
            return "{\(val)}"
        case .anything,
             .catchall:
            throw OpenAPIPathComponentError.unsupportedPathComponent(String(describing: self))
        }
    }

    internal var openAPIPathParameter: OpenAPI.PathItem.Parameter? {
        switch self {
        case .parameter(let name):
            return .init(
                name: name,
                parameterLocation: .path,
                schema: .string
            )
        default:
            return nil
        }
    }

    enum OpenAPIPathComponentError: Swift.Error {
        case unsupportedPathComponent(String)
    }
}