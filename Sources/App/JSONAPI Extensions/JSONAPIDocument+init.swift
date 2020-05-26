//
//  JSONAPIDocument+init.swift
//  
//
//  Created by Mathew Polzin on 5/16/20.
//

import Foundation
import JSONAPI

extension Document.SuccessDocument where PrimaryResourceBody: SingleResourceBodyProtocol, PrimaryResourceBody.PrimaryResource: ResourceObjectType, MetaType == NoMetadata, LinksType == NoLinks, APIDescription == NoAPIDescription {
    init(resource: Document.CompoundResource) {
        self.init(
            apiDescription: .none,
            resource: resource,
            meta: .none,
            links: .none
        )
    }
}

extension Document.SuccessDocument where PrimaryResourceBody: ManyResourceBodyProtocol, PrimaryResourceBody.PrimaryResource: ResourceObjectType, MetaType == NoMetadata, LinksType == NoLinks, APIDescription == NoAPIDescription, IncludeType: Hashable {
    init(resources: [Document.CompoundResource]) {
        self.init(
            apiDescription: .none,
            resources: resources,
            meta: .none,
            links: .none
        )
    }
}

// TODO: delete following after fully adopting prior two alternatives
extension Document.SuccessDocument where MetaType == NoMetadata, LinksType == NoLinks, APIDescription == NoAPIDescription {
    init(body: PrimaryResourceBody) {
        self.init(
            apiDescription: .none,
            body: body,
            includes: .none,
            meta: .none,
            links: .none
        )
    }
}
