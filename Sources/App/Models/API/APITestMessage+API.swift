//
//  APITestMessage+API.swift
//  
//
//  Created by Mathew Polzin on 4/22/20.
//

import Foundation
import APIModels
import Fluent
import Vapor
import OpenAPIReflection
import JSONAPI

extension API {
    /// Pass a query builder where the first result will be used.
    static func singleAPITestMessageResponse(query: QueryBuilder<DB.APITestMessage>, includeTestDescriptor: Bool) -> EventLoopFuture<SingleAPITestMessageDocument.SuccessDocument> {

        var query = query

        if includeTestDescriptor {
            query = query.with(\.$apiTestDescriptor) {
                $0.with(\.$messages)
            }
        }

        let primaryFuture = query.first()

        let resourceFuture = primaryFuture.flatMapThrowing { try $0?.jsonApiResources() }
            .unwrap(or: Abort(.notFound))

        let responseFuture = resourceFuture
            .map(SingleAPITestMessageDocument.SuccessDocument.init)

        return responseFuture
    }
}

extension API.MessageType: AnyJSONCaseIterable {}
