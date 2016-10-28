//
//  Actions.swift
//  Leo
//
//  Created by Adam Fanslau on 10/26/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

import Foundation

public class ActionTypes : NSObject {
    static let ScheduleNewAppointment = "SCHEDULE_NEW_APPOINTMENT"
    static let ChangeCardState = "CHANGE_CARD_STATE"
}

public class Action : NSObject {
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
}

public class ActionCreators {
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

