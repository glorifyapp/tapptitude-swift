//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

struct APIError: Error {
    enum `Type`: String {
        case missingSession = "MissingSession"
        case unkown
    }
    
    var code: String // switch to `Int` type if backend return
    var message: String
    var type: Type
}


extension APIError: Decodable {
    private enum CodingKeys: String, CodingKey {
        case code, message
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        message = try values.decode(String.self, forKey: .message)
        type = Type(rawValue: code) ?? .unkown
    }
}


func ==(lhs: APIError, rhs: Error) -> Bool {
    let error = rhs as NSError
    return error.domain == lhs.type.rawValue
}

func ==(lhs: Error, rhs: APIError) -> Bool {
    let error = lhs as NSError
    return error.domain == rhs.type.rawValue
}

func ==(lhs: Error, rhs: APIError.`Type`) -> Bool {
    let error = lhs as NSError
    return error.domain == rhs.rawValue
}
