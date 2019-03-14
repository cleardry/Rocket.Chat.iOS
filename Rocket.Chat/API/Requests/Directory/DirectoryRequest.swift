//
//  DirectoryRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 08/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/directory/

import SwiftyJSON

enum DirectoryRequestType: String {
    case users
    case channels
}

final class DirectoryRequest: APIRequest {
    typealias APIResourceType = DirectoryResource

    let version = Version(0, 65, 0)
    let path = "/api/v1/directory"

    let query: String?

    init(query: String, type: DirectoryRequestType) {
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.query = "query={\"text\": \"\(encodedQuery)\", \"type\": \"\(type)\"}"
        } else {
            self.query = "query={\"type\": \"\(type)\"}"
        }
    }
}

/*
 Careful when using the results of DirectoryResource, because the
 API can return different type of objects inside the same array
 called "results". When getting the results, you will need to
 make sure you're trying to access the correct property.
 */
final class DirectoryResource: APIResource {
    var users: [UnmanagedUser] {
        return raw?["result"].arrayValue.compactMap {
            let user = User()
            user.map($0, realm: nil)
            return user.unmanaged
        } ?? []
    }

    var channels: [UnmanagedSubscription] {
        return raw?["result"].arrayValue.compactMap {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            subscription.mapRoom($0, realm: nil)
            return subscription.unmanaged
        } ?? []
    }

    var count: Int? {
        return raw?["count"].int
    }

    var offset: Int? {
        return raw?["offset"].int
    }

    var total: Int? {
        return raw?["total"].int
    }
}