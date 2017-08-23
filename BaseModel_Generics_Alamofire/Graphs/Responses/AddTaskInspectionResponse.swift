//
//  AddTaskInspectionResponse.swift
//  BaseModel-Generics-Alamofire
//
//  Created by Komsit on 05/22/2017.
//  Copyright © 2017 Komsit. All rights reserved.
//

import Foundation
import Gloss

struct AddTaskInspectionResponse: Decodable {
    let taskId: String?
    
    init?(json: JSON) {
        self.taskId = "task_id" <~~ json
    }
}
