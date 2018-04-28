//
//  ARSceneViewHandler.swift
//  QuestPlatformMobileApp
//
//  Created by Anton Poltoratskyi on 28.04.2018.
//  Copyright © 2018 Anton Poltoratskyi. All rights reserved.
//

import ARKit
import SceneKit

public final class ARSceneViewHandler: NSObject {
    
    public weak var delegate: ARSceneViewHandlerDelegate?
    public weak var scene: ARSCNView!
    
    public var state: ARSceneViewState = .limitedInitializing {
        didSet {
            delegate?.sceneViewHandler(self, didUpdateState: state)
        }
    }
    
    private var session: ARSession {
        return scene.session
    }
    
    private let updateQueue = DispatchQueue(label: "scene-update-queue")
    
    private var displayFloor = true
    private var recognizedHeights: [ARAnchor: Float] = [:]
    private var floorNodes: [ARAnchor: FloorNode] = [:]
    
    
    // MARK: - Init
    
    public init(with scene: ARSCNView) {
        self.scene = scene
        
        super.init()
        if ARWorldTrackingConfiguration.isSupported {
            setup()
        }
    }
    
    
    // MARK: - Setup
    
    private func setup() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
        
        if let camera = scene.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
        }
    }
    
    private func setupScene() {
        scene.delegate = self
        session.delegate = self
        
        scene.scene = SCNScene()
        
        scene.automaticallyUpdatesLighting = true
        scene.autoenablesDefaultLighting = true
        
        scene.debugOptions = [
            ARSCNDebugOptions.showWorldOrigin,
            ARSCNDebugOptions.showFeaturePoints
        ]
    }
    
    private func clearStoredDate() {
        recognizedHeights.removeAll()
        floorNodes.removeAll()
    }
}

// MARK: - Public Input
extension ARSceneViewHandler: ARSceneViewHandlerInput {
    
    public func currentCameraTransform() -> matrix_float4x4? {
        return session.currentFrame?.camera.transform
    }
    
    public func estimatedHeight() -> Float {
        return recognizedHeights.values.min() ?? -1.5
    }
    
    public func launchSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        clearStoredDate()
        let configuration = state.configuration
        session.run(configuration)
    }
    
    public func pauseSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        session.pause()
    }
    
    public func reloadSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        let options: ARSession.RunOptions =  [.resetTracking, .removeExistingAnchors]
        let configuration = state.configuration
        session.run(configuration, options: options)
    }
    
    public func addNode(_ node: SCNNode) {
        scene?.scene.rootNode.addChildNode(node)
    }
    
    public func addNodes(_ nodes: [SCNNode]) {
        nodes.forEach { addNode($0) }
    }
    
    public func removeAllNodes() -> [SCNNode] {
        let nodesToRemove = scene?.scene.rootNode.childNodes ?? []
        nodesToRemove.forEach { $0.removeFromParentNode() }
        return nodesToRemove
    }
}

// MARK: - ARSCNViewDelegate
extension ARSceneViewHandler: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        recognizedHeights[anchor] = node.position.y
        
        let floorNode = FloorNode(anchor: anchor)
        floorNode.setColor(UIColor.white.withAlphaComponent(0.2))
        node.addChildNode(floorNode)
        floorNodes[anchor] = floorNode
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        recognizedHeights[anchor] = node.position.y
        
        guard let floorNode = floorNodes[anchor] else { return }
        floorNode.updatePostition(anchor)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        recognizedHeights[anchor] = nil
        floorNodes[anchor] = nil
    }
}

// MARK: - ARSessionDelegate
extension ARSceneViewHandler: ARSessionDelegate {
    
    public func updateState(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            state = .normalEmptyAnchors
        case .normal:
            state = .normal
        case .notAvailable:
            state = .notAvailable
        case .limited(.excessiveMotion):
            state = .limitedExcessiveMotion
        case .limited(.insufficientFeatures):
            state = .limitedInsufficientFeatures
        case .limited(.initializing):
            state = .limitedInitializing
        case .limited(.relocalizing):
            state = .relocalizing
        }
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: camera.trackingState)
    }
}

// MARK: - ARSessionObserver
extension ARSceneViewHandler {
    
    public func sessionWasInterrupted(_ session: ARSession) {
        state = .interrupted
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        state = .interruptionEnded
        reloadSession()
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        state = .failed(error)
        reloadSession()
    }
}
