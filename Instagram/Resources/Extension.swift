//
//  Extension.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation
import UIKit

extension UIView {
    var top: CGFloat {
        frame.origin.y
    }
    var bottom: CGFloat {
        frame.origin.y + height
    }
    var left: CGFloat  {
        frame.origin.x
    }
    var right: CGFloat  {
        frame.origin.x + width
    }
    var width: CGFloat {
        frame.size.width
    }
    var height: CGFloat {
        frame.size.height
    }
}

extension Decodable {
    ///Change Dictionary to a decodable Data type
    init?(with dictionary: [String:Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {return nil}
        
        guard let result = try? JSONDecoder().decode(Self.self, from: data) else {return nil}
        
        self = result
    }
}


extension Encodable {
    func asDictionary() -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
        
        return json
    }
}

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    static func date(from date: Date) -> String? {
        let formatter = DateFormatter.formatter
        let string = formatter.string(from: date)
        return string
    }
}

extension Notification.Name {
    static let didPostNotification = Notification.Name("didPostNotification")
}


extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}
