//
//  Actions.swift
//  Leo
//
//  Created by Adam Fanslau on 10/26/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

import Foundation

class ActionTypes : NSObject {
    static let ScheduleNewAppointment = "SCHEDULE_NEW_APPOINTMENT"
    static let ChangeCardState = "CHANGE_CARD_STATE"
    static let DismissCard = "DISMISS_CARD"
}

class Action : NSObject, JSONSerializable {
    let actionType: String
    let payload: [String : Any]
    let displayName: String?

    init(
      actionType: String,
      payload: [String : Any],
      displayName: String?
    ) {
      self.actionType = actionType
      self.payload = payload
      self.displayName = displayName

      super.init()
    }

    static func json(_ objects: [Action]) -> [JSON] {
        return objects.map({object in object.json()})
    }

    static func initMany(jsonArray: [JSON]) -> [Action] {
        return jsonArray
            .map({ Action(json: $0) })
            .filter({ $0 != nil })
            .map({ $0! })
    }

    required convenience init?(json: JSON) {
        guard let actionType = json["action_type"] as? String else { return nil }
        guard let payload = json["payload"] as? JSON else { return nil }
        guard let displayName = json["display_name"] as? String? else { return nil }

        self.init(
            actionType: actionType,
            payload: payload,
            displayName: displayName
        )
    }

    func json() -> JSON {
        return [
          "action_type": actionType,
          "payload": payload,
          "display_name": displayName
        ]
    }
}

class ActionCreators {
    class func action(json: [String : Any]) -> Action {
        return Action(
            actionType: json["action_type"] as! String,
            payload: json["payload"] as! [String : Any],
            displayName: json["display_name"] as! String?
        )
    }

    class func scheduleNewAppointment() -> Action {
        return Action(
            actionType: ActionTypes.ScheduleNewAppointment,
            payload: [:],
            displayName: nil
        )
    }
}
