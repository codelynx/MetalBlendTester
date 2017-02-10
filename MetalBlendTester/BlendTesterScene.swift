//
//  BlendTesterScene.swift
//  MetalBlendTester
//
//  Created by Kaz Yoshikawa on 2/10/17.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

class BlendTesterScene: Scene {

	lazy var sourceImageTexture: MTLTexture = {
		return self.device.texture(of: XImage(named: "sample1")!)!
	}()

	lazy var destinationImageTexture: MTLTexture = {
		return self.device.texture(of: XImage(named: "sample2")!)!
	}()

	// mark: -

    var rgbBlendOperation: MTLBlendOperation {
		get { return self.blendRenderer.rgbBlendOperation }
		set { self.blendRenderer.rgbBlendOperation = newValue }
	}
    var alphaBlendOperation: MTLBlendOperation {
		get { return self.blendRenderer.alphaBlendOperation }
		set { self.blendRenderer.alphaBlendOperation = newValue }
	}

    var sourceRGBBlendFactor: MTLBlendFactor {
		get { return self.blendRenderer.sourceRGBBlendFactor }
		set { self.blendRenderer.sourceRGBBlendFactor = newValue }
	}
    var destinationRGBBlendFactor: MTLBlendFactor {
		get { return self.blendRenderer.destinationRGBBlendFactor }
		set { self.blendRenderer.destinationRGBBlendFactor = newValue }
	}

    var sourceAlphaBlendFactor: MTLBlendFactor {
		get { return self.blendRenderer.sourceAlphaBlendFactor }
		set { self.blendRenderer.sourceAlphaBlendFactor = newValue }
	}
    var destinationAlphaBlendFactor: MTLBlendFactor{
		get { return self.blendRenderer.destinationAlphaBlendFactor }
		set { self.blendRenderer.destinationAlphaBlendFactor = newValue }
	}

	// mark: -

	lazy var colorRenderer: ColorRenderer = {
		return self.device.renderer() as ColorRenderer
	}()

	lazy var colorVertexBuffer: VertexBuffer<ColorRenderer.Vertex> = {
		let vertices = self.colorRenderer.vertices(for: Rect(self.bounds), color: XColor.black)
		return self.colorRenderer.vertexBuffer(for: vertices)!
	}()

	lazy var blendRenderer: BlendTesterRenderer = {
		return self.device.renderer() as BlendTesterRenderer
	}()

	lazy var vertexBuffer: VertexBuffer<BlendTesterRenderer.Vertex> = {
		return self.blendRenderer.vertexBuffer(for: Rect(self.bounds))!
	}()
	
	override func didMove(to renderView: RenderView) {
		super.didMove(to: renderView)
		renderView.backgroundColor = XColor.white
		self.backgroundColor = XColor.white
	}

	override func render(in context: RenderContext) {

		self.colorRenderer.render(context: context, rect: Rect(self.bounds), color: XColor.blue)
		self.blendRenderer.renderImage(context: context, texture: self.destinationImageTexture, vertexBuffer: self.vertexBuffer)
		self.blendRenderer.renderImage(context: context, texture: self.sourceImageTexture, vertexBuffer: self.vertexBuffer)
	}

}
