//
//	ViewController.swift
//	MetalBlendTester
//
//	Created by Kaz Yoshikawa on 2/10/17.
//	Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Cocoa
import MetalKit


class ViewController: NSViewController {

	@IBOutlet weak var renderView: RenderView!

	@IBOutlet weak var rgbBlendOperationPopup: NSPopUpButton!
	@IBOutlet weak var alphaBlendOperationPopup: NSPopUpButton!

	@IBOutlet weak var sourceRGBBlendFactorPopup: NSPopUpButton!
	@IBOutlet weak var sourceAlphaBlendFactorPopup: NSPopUpButton!
	@IBOutlet weak var destinationRGBBlendFactorPopup: NSPopUpButton!
	@IBOutlet weak var destinationAlphaBlendFactorPopup: NSPopUpButton!

	// MARK: -

    var rgbBlendOperation: MTLBlendOperation {
		get { return self.blendTesterScene.rgbBlendOperation }
		set { self.blendTesterScene.rgbBlendOperation = newValue }
	}
    var alphaBlendOperation: MTLBlendOperation {
		get { return self.blendTesterScene.alphaBlendOperation }
		set { self.blendTesterScene.alphaBlendOperation = newValue }
	}

    var sourceRGBBlendFactor: MTLBlendFactor {
		get { return self.blendTesterScene.sourceRGBBlendFactor }
		set { self.blendTesterScene.sourceRGBBlendFactor = newValue }
	}
    var sourceAlphaBlendFactor: MTLBlendFactor {
		get { return self.blendTesterScene.sourceAlphaBlendFactor }
		set { self.blendTesterScene.sourceAlphaBlendFactor = newValue }
	}

    var destinationRGBBlendFactor: MTLBlendFactor {
		get { return self.blendTesterScene.destinationRGBBlendFactor }
		set { self.blendTesterScene.destinationRGBBlendFactor = newValue }
	}
    var destinationAlphaBlendFactor: MTLBlendFactor{
		get { return self.blendTesterScene.destinationAlphaBlendFactor }
		set { self.blendTesterScene.destinationAlphaBlendFactor = newValue }
	}
	
	// MARK: -
	
	@IBAction func rgbBlendOperationAction(_ sender: NSPopUpButton) {
		let seletedIndex = sender.indexOfSelectedItem
		if let operation = MTLBlendOperation(rawValue: UInt(seletedIndex)) {
			self.rgbBlendOperation = operation
		}
		self.renderView.setNeedsDisplay()
	}

	@IBAction func alphaBlendOperationAction(_ sender: NSPopUpButton) {
		let seletedIndex = sender.indexOfSelectedItem
		if let operation = MTLBlendOperation(rawValue: UInt(seletedIndex)) {
			self.alphaBlendOperation = operation
		}
	}

	@IBAction func sourceRGBBlendFactorAction(_ sender: NSPopUpButton) {
		let seletedIndex = sender.indexOfSelectedItem
		if let factor = MTLBlendFactor(rawValue: UInt(seletedIndex)) {
			self.sourceRGBBlendFactor = factor
		}
		self.renderView.setNeedsDisplay()
	}

	@IBAction func sourceAlphaBlendFactorAction(_ sender: NSPopUpButton) {
		let seletedIndex = sender.indexOfSelectedItem
		if let factor = MTLBlendFactor(rawValue: UInt(seletedIndex)) {
			self.sourceAlphaBlendFactor = factor
		}
		self.renderView.setNeedsDisplay()
	}

	@IBAction func destinationRGBBlendFactorAction(_ sender: NSPopUpButton) {
		let seletedIndex = sender.indexOfSelectedItem
		if let factor = MTLBlendFactor(rawValue: UInt(seletedIndex)) {
			self.destinationRGBBlendFactor = factor
		}
		self.renderView.setNeedsDisplay()
	}

	@IBAction func destinationAlphaBlendFactorAction(_ sender: NSPopUpButton) {
		let seletedIndex = sender.indexOfSelectedItem
		if let factor = MTLBlendFactor(rawValue: UInt(seletedIndex)) {
			self.destinationAlphaBlendFactor = factor
		}
		self.renderView.setNeedsDisplay()
	}

//	@IBAction func sourceRGBBlendFactorMenu(: NSMenu!
//	@IBOutlet weak var sourceAlphaBlendFactorMenu: NSMenu!
//
//	@IBOutlet weak var destinationRGBBlendFactorMenu: NSMenu!
//	@IBOutlet weak var destinationAlphaBlendFactorMenu: NSMenu!


	lazy var blendTesterScene: BlendTesterScene = {
		return BlendTesterScene(device: self.renderView.device, contentSize: CGSize(512, 512))!
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.renderView.scene = self.blendTesterScene
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()

		self.rgbBlendOperationPopup.selectItem(at: Int(self.rgbBlendOperation.rawValue))
		self.alphaBlendOperationPopup.selectItem(at: Int(self.alphaBlendOperation.rawValue))
		
		self.sourceRGBBlendFactorPopup.selectItem(at: Int(self.sourceRGBBlendFactor.rawValue))
		self.sourceAlphaBlendFactorPopup.selectItem(at: Int(self.sourceAlphaBlendFactor.rawValue))
		self.destinationRGBBlendFactorPopup.selectItem(at: Int(self.destinationRGBBlendFactor.rawValue))
		self.destinationAlphaBlendFactorPopup.selectItem(at: Int(self.destinationAlphaBlendFactor.rawValue))
	}

	override var representedObject: Any? {
		didSet {
		}
	}

	
}

/*
    case zero
    case one
    case sourceColor
    case oneMinusSourceColor

    case sourceAlpha

    case oneMinusSourceAlpha

    case destinationColor

    case oneMinusDestinationColor

    case destinationAlpha

    case oneMinusDestinationAlpha

    case sourceAlphaSaturated

    case blendColor

    case oneMinusBlendColor

    case blendAlpha

    case oneMinusBlendAlpha

    @available(OSX 10.12, *)
    case source1Color

    @available(OSX 10.12, *)
    case oneMinusSource1Color

    @available(OSX 10.12, *)
    case source1Alpha

    @available(OSX 10.12, *)
    case oneMinusSource1Alpha
*/
