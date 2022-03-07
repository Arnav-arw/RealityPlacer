//
//  ContentView.swift
//  RealityPlacer
//
//  Created by Arnav Singhal on 07/03/22.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State var confirmedSelectedModel: Model?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(confirmedSelectedModel: $confirmedSelectedModel)
                .ignoresSafeArea()
            if isPlacementEnabled {
                bottomButtons
            } else {
                modelPickerView
            }
        }
    }
    
    // MODEL
    private var modelNames: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath,
              let files = try? filemanager.contentsOfDirectory(atPath: path)
        else {
            return []
        }
        var availabeModelNames: [Model] = []
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            availabeModelNames.append(Model(modelName: modelName))
        }
        return availabeModelNames
    }()
    
    // VIEWS
    private var modelPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< modelNames.count, id: \.self) { index in
                    Button {
                        print("Selected Item is ", modelNames[index].modelName )
                        selectedModel = modelNames[index]
                        isPlacementEnabled = true
                    } label: {
                        Image(uiImage: modelNames[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(.white)
                            .cornerRadius(20)
                        
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
    
    private var bottomButtons: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button {
                print("You just pressed cancel button")
                isPlacementEnabled = false
                selectedModel = nil
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(20)
                    .padding(20)
            }
            Spacer()
            Button {
                print("You just pressed confirm button")
                isPlacementEnabled = false
                confirmedSelectedModel = selectedModel
                selectedModel = nil
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(20)
                    .padding(20)
            }
        }
    }
}

class CustomARView: ARView {
    let focusSquare = FESquare()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        setupARView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init coder hasnt been implemented")
    }
    
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        self.session.run(config)
    }
}

extension CustomARView: FEDelegate {
    func toTrackingState() {
        print("tracking")
    }
    func toInitializingState() {
        print("initiale")
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var confirmedSelectedModel: Model?
    
    func makeUIView(context: Context) -> ARView {
        let arView = CustomARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = confirmedSelectedModel {
            if let modelEntity = model.modelEntity {
                print("Adding \(model.modelName) to the scene")
                let anchorEntity = AnchorEntity(plane: .horizontal)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("Cant load \(model.modelName)")
            }
           
            DispatchQueue.main.async {
                confirmedSelectedModel = nil
            }
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
