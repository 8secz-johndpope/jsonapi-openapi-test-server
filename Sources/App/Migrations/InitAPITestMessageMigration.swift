//
//  InitAPITestMessageMigration.swift
//  App
//
//  Created by Mathew Polzin on 9/23/19.
//

import Fluent
import SQLKit

public struct InitAPITestMessageMigration: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {

        return database.schema(APITestMessage.schema)
            .field("id", .uuid, .identifier(auto: false))
            .field("created_at", .datetime, .required)
            .field("message_type", .string, .required)
            .field("path", .string)
            .field("context", .string)
            .field("message", .string, .required)
            .field("api_test_descriptor_id", .uuid, .required)
//                   .foreignKey(parentTable: APITestDescriptor.schema,
//                               parentField: .string("id"),
//                               updateAction: .cascade,
//                               deleteAction: .cascade))
//            .foreignKey("api_test_descriptor_id",
//                        references: (table: APITestDescriptor.schema, field: "id"),
//                        onUpdate: .cascade, onDelete: .cascade)
            .create()
            .map { _ -> SQLDatabase? in database as? SQLDatabase }
            .optionalFlatMap { sqlDb in
                // super unforunate thing has to be done
                // because multiple column constraints currently
                // fail above.
                sqlDb.raw("ALTER TABLE \(APITestMessage.schema) ADD FOREIGN KEY (api_test_descriptor_id) REFERENCES \(APITestDescriptor.schema)(id) ON UPDATE CASCADE ON DELETE CASCADE")
                    .run()
        }.transform(to: ())
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(APITestMessage.schema).delete()
    }
}
