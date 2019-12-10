
import App
import AppAPIDocumentation
import Foundation
import Yams

let dummyApp = try app(.detect(), hobbled: true)

let routes = dummyApp.routes

let documentation = try OpenAPIDocs(
    contentConfig: .default(),
    routes: routes
)

dummyApp.shutdown()

let documentationString = try YAMLEncoder().encode(documentation.document)

print(documentationString)
