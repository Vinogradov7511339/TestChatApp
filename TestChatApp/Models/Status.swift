//
//  Status.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import Foundation

enum Status: String, CaseIterable {
    case available = "Available"
    case busy = "Busy"
    case atSchool = "At School"
    case atTheMovies = "At The Movies"
    case atWork = "At Work"
    case batteryAboutToDie = "Battery About to die"
    case cantTalk = "Can't talk"
    case inAMeeting = "In a meeting"
    case atTheGym = "At the gym"
    case sleeping = "Sleeping"
    case urgentCallsOnly = "Urgent calls only"
}
