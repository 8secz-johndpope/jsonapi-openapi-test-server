//
//  APITestProperties+APIModel.swift
//  
//
//  Created by Mathew Polzin on 4/28/20.
//

import Foundation
import JSONAPI
import Poly

extension API {
    public enum APITestPropertiesDescription: JSONAPI.ResourceObjectDescription {
        public static let jsonType: String = "api_test_properties"

        public struct Attributes: JSONAPI.SparsableAttributes {
            public let createdAt: Attribute<Date>
            public let apiHostOverride: Attribute<URL?>
            public let parser: Attribute<Parser>

            public init(
                createdAt: Date,
                apiHostOverride: URL?,
                parser: Parser
            ) {
                self.createdAt = .init(value: createdAt)
                self.apiHostOverride = .init(value: apiHostOverride)
                self.parser = .init(value: parser)
            }

            public enum CodingKeys: SparsableCodingKey {
                case createdAt
                case apiHostOverride
                case parser
            }
        }

        public struct Relationships: JSONAPI.Relationships {
            public let openAPISource: ToOneRelationship<OpenAPISource, NoMetadata, NoLinks>

            public init(openAPISource: OpenAPISource) {
                self.openAPISource = .init(resourceObject: openAPISource)
            }

            public init(openAPISource: OpenAPISource.Pointer) {
                self.openAPISource = openAPISource
            }

            public init(openAPISourceId: OpenAPISource.Id) {
                self.openAPISource = .init(id: openAPISourceId)
            }
        }
    }

    public enum NewAPITestPropertiesDescription: JSONAPI.ResourceObjectDescription {
        public static let jsonType: String = APITestProperties.jsonType

        public struct Attributes: JSONAPI.Attributes {
            public let apiHostOverride: Attribute<URL?>
            public let parser: Attribute<Parser>

            public init(apiHostOverride: URL?, parser: Parser) {
                self.apiHostOverride = .init(value: apiHostOverride)
                self.parser = .init(value: parser)
            }
        }

        public struct Relationships: JSONAPI.Relationships {
            public let openAPISource: ToOneRelationship<OpenAPISource, NoMetadata, NoLinks>?

            public init(openAPISource: ToOneRelationship<OpenAPISource, NoMetadata, NoLinks>? = nil) {
                self.openAPISource = openAPISource
            }
        }
    }

    public typealias APITestProperties = JSONAPI.ResourceObject<APITestPropertiesDescription, NoMetadata, NoLinks, UUID>
    public typealias NewAPITestProperties = JSONAPI.ResourceObject<NewAPITestPropertiesDescription, NoMetadata, NoLinks, Unidentified>

    public typealias BatchAPITestPropertiesDocument = BatchDocument<APITestProperties, Include1<OpenAPISource>>

    public typealias SingleAPITestPropertiesDocument = SingleDocument<APITestProperties, Include1<OpenAPISource>>

    public typealias CreateAPITestPropertiesDocument = SingleDocument<NewAPITestProperties, NoIncludes>.SuccessDocument
}

extension API {
    public enum Parser: String, Codable, CaseIterable {
        case fast = "fast"
        case stable = "stable"
    }
}
