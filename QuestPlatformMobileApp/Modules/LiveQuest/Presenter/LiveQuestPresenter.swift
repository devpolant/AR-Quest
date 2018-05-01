//
//  LiveQuestPresenter.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 28.04.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit

final class LiveQuestPresenter: Presenter, QuestModuleInput {
    
    typealias View = QuestViewInput
    typealias Interactor = QuestInteractorInput
    typealias Router = QuestRouterInput
    
    weak var view: View!
    var interactor: Interactor!
    var router: Router!
    
    private var sceneHandler: ARSceneViewModelInput!
    
    private let trackingService: ARTrackingService = {
        let service = ARTrackingService()
        return service
    }()
    
    private let quest: Quest
    
    private var currentTask: Task? {
        didSet {
            guard let task = currentTask else {
                handleQuestFinish()
                return
            }
            switch task.goal {
            case let .hint(text):
                if !isTextPopupPresented {
                    showHint(text)
                    view.enableNextAction()
                }
            case let .location(destinationCoordinate):
                updateDestinationNodePosition(for: destinationCoordinate)
            }
        }
    }
    
    private let updateQueue = DispatchQueue.queue(for: LiveQuestPresenter.self)
    
    private var isTextPopupPresented = false
    private var isFinished = false
    
    
    // MARK: - Init
    
    init(quest: Quest) {
        self.quest = quest
    }
    
    deinit {
        deinited(self)
    }
}

// MARK: - QuestViewOutput
extension LiveQuestPresenter: QuestViewOutput {
    
    func viewDidLoad() {
        view.disableNextButton()
        
        let handler = ARSceneViewModel(with: view.sceneView)
        handler.delegate = self
        sceneHandler = handler
        
        self.currentTask = quest.tasks.first
        
        trackingService.delegate = self
        interactor.startLocationUpdates()
    }
    
    func viewDidAppear() {
        sceneHandler.launchSession()
    }
    
    func viewDidDisappear() {
        sceneHandler.pauseSession()
    }
    
    func didHideTextPopup() {
        view.disableNextButton()
        updateQueue.sync {
            self.isTextPopupPresented = false
        }
        goToNextTask()
    }
    
    private func goToNextTask() {
        currentTask = quest.tasks.next(after: { $0 === currentTask })
    }
}


// MARK: - QuestInteractorOutput
extension LiveQuestPresenter: QuestInteractorOutput {
    
    func didChangeLocationAuthorizationStatus(_ status: CLAuthorizationStatus) {
        print("Authorization status: \(status)")
    }
    
    func didUpdateLocation(_ newLocation: CLLocation, previousLocation: CLLocation?) {
        guard let cameraTransform = sceneHandler.currentCameraTransform() else {
            return
        }
        trackingService.handleLocationUpdate(newLocation: newLocation, currentCameraTransform: cameraTransform)
    }
    
    func didUpdateHeading(_ newHeading: CLHeading) {
    }
    
    func didReceiveLocationFailure(_ error: Error) {
        view.showMessage(error.localizedDescription)
    }
}

// MARK: - ARSceneViewModelDelegate
extension LiveQuestPresenter: ARSceneViewModelDelegate {
    
    func sceneViewModel(_ sceneModel: ARSceneViewModel, didUpdateState state: ARSceneViewState) {
        switch state {
        case .normal, .normalEmptyAnchors:
            break
        default:
            break
        }
    }
}

// MARK: - Task Actions
extension LiveQuestPresenter {
    
    private func handleQuestFinish() {
        updateQueue.async {
            guard !self.isFinished else {
                return
            }
            self.isFinished = true
            
            DispatchQueue.main.async {
                self.view.disableNextButton()
                self.router.showFinish(for: self.quest)
            }
        }
    }
    
    private func showHint(_ text: String) {
        updateQueue.async {
            guard !self.isTextPopupPresented else {
                return
            }
            self.isTextPopupPresented = true
            
            DispatchQueue.main.async {
                self.removeDestinationNode()
                self.view.enableNextAction()
                self.view.showTextPopup(text)
            }
        }
    }
    
    private func handleDistanceToDestination(_ distance: Distance) {
        updateQueue.async {
            // < 10 meters
            DispatchQueue.main.async {
                print("Dis: \(distance)")
                
                self.view.showDistance(distance)
                if distance < 5 {
                    self.goToNextTask()
                }
            }
        }
    }
}

// MARK: - ARTrackingServiceDelegate
extension LiveQuestPresenter: ARTrackingServiceDelegate {
    
    func didUpdateTrackedPosition(with trackingInfo: TrackingInfo) {
        DispatchQueue.main.async {
            let accuracy = trackingInfo.accuracy()
            self.view.showMessage("Accuracy: \u{0394} \(accuracy) m.")
            
            if accuracy <= 1 && accuracy >= 0.0001 {
                guard let currentTask = self.currentTask, case let .location(destinationCoordinate) = currentTask.goal else {
                    return
                }
                self.updateDestinationNodePosition(for: destinationCoordinate)
            }
        }
    }
    
    func didStartPositionTracking() {
    }
    
    func handleARSessionReset() {
        sceneHandler.reloadSession()
    }
}

// MARK: - Nodes

extension LiveQuestPresenter {
    
    private func updateDestinationNodePosition(for location: Coordinate) {
        guard let camera = sceneHandler?.currentCameraTransform(),
            let currentLocation = trackingService.lastRecognizedLocation else {
                return
        }
        let identifier = "destination-location"
        
        var existingNodes: [DestinationNode] = view.sceneView.scene.rootNode.childNodes {
            $0.identifier == identifier
        }
        if existingNodes.isEmpty {
            let destinationNode = DestinationNode(coordinate: location, identifier: identifier)
            view.sceneView.scene.rootNode.addChildNode(destinationNode)
            existingNodes.append(destinationNode)
        }
        
        for node in existingNodes {
            node.update(with: camera,
                        currentCoordinates: currentLocation.coordinate,
                        thresholdDistance: SceneUtils.sceneRadius)
        }
        
        let estimatedFloorHeight = sceneHandler.estimatedHeight()
        SCNTransaction.animate(withDuration: 0.25, animations: {
            for node in existingNodes {
                let distance = currentLocation.coordinate.distance(to: location)
                let sceneDistance = distance > SceneUtils.sceneRadius ? SceneUtils.sceneRadius : distance
                
                node.applyScale(self.scaleForDistance(sceneDistance))
                node.applyHeight(self.heightForDistance(distance, floorHeight: estimatedFloorHeight))
                
                self.handleDistanceToDestination(distance)
            }
        })
    }
    
    private func removeDestinationNode() {
        let nodes: [DestinationNode] = view.sceneView.scene.rootNode.childNodes {
            $0.identifier == "destination-location"
        }
        for node in nodes {
            node.removeFromParentNode()
        }
    }
    
    private func heightForDistance(_ distance: Double, floorHeight: Float) -> Float {
        if distance < 10 {
            return 1 + Float(distance) + floorHeight
        }
        return 10 + floorHeight
    }
    
    private func scaleForDistance(_ distance: Double) -> Float {
        var scale = Float(distance) * 0.3
        if scale < 2 {
            scale = 2
        }
        return scale
    }
}

// MARK: - Collection
extension Collection {
    
    func next(after predicate: (Iterator.Element) -> Bool) -> Iterator.Element? {
        var idx: Index? = nil
        for (i, element) in zip(indices, self) {
            if predicate(element) {
                idx = i
                break
            }
        }
        
        if let index = idx,
            let resultIndex = self.index(index, offsetBy: 1, limitedBy: self.endIndex),
            resultIndex != endIndex {
            
            return self[resultIndex]
        }
        return nil
    }
}
