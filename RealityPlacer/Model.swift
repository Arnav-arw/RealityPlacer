//
//  model.swift
//  RealityPlacer
//
//  Created by Arnav Singhal on 07/03/22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        self.cancellable = ModelEntity.loadModelAsync(named: (modelName + ".usdz"))
            .sink(receiveCompletion: { loadCompletetion in
                print("Not able to laod the model :(")
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
            })
    }
}
