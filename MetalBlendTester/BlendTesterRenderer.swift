//
//	ImageRenderer.swift
//	Silvershadow
//
//	Created by Kaz Yoshikawa on 12/22/15.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import Metal
import MetalKit
import GLKit


//
//	BlendTesterRenderer
//

class BlendTesterRenderer: Renderer {

	typealias VertexType = Vertex

	// MARK: -

	struct Vertex {
		var x, y, z, w, u, v: Float
	}

	struct Uniforms {
		var transform: GLKMatrix4
	}


	let device: MTLDevice
	

	required init(device: MTLDevice) {
		self.device = device
	}

    var rgbBlendOperation: MTLBlendOperation = .add { didSet { self.reset() } }
    var alphaBlendOperation: MTLBlendOperation = .add { didSet { self.reset() } }

    var sourceRGBBlendFactor: MTLBlendFactor = .sourceAlpha { didSet { self.reset() } }
    var destinationRGBBlendFactor: MTLBlendFactor = .oneMinusSourceAlpha { didSet { self.reset() } }

    var sourceAlphaBlendFactor: MTLBlendFactor = .sourceAlpha { didSet { self.reset() } }
    var destinationAlphaBlendFactor: MTLBlendFactor = .oneMinusSourceAlpha { didSet { self.reset() } }

	func vertices(for rect: Rect) -> [Vertex] {
		let (l, r, t, b) = (rect.minX, rect.maxX, rect.maxY, rect.minY)

		//	vertex	(y)		texture	(v)
		//	1---4	(1) 		a---d 	(0)
		//	|	|			|	|
		//	2---3 	(0)		b---c 	(1)
		//

		return [
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 0),		// 1, a
			Vertex(x: l, y: b, z: 0, w: 1, u: 0, v: 1),		// 2, b
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 1),		// 3, c

			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 0),		// 1, a
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 1),		// 3, c
			Vertex(x: r, y: t, z: 0, w: 1, u: 1, v: 0),		// 4, d
		]
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .float4
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.attributes[1].offset = 0
		vertexDescriptor.attributes[1].format = .float2
		vertexDescriptor.attributes[1].bufferIndex = 0
		
		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	func reset() {
		self.renderPipelineState = nil
	}

	lazy var renderPipelineState: MTLRenderPipelineState! = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "image_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "image_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = defaultPixelFormat
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = self.rgbBlendOperation
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = self.alphaBlendOperation

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = self.sourceRGBBlendFactor
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = self.sourceAlphaBlendFactor
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = self.destinationRGBBlendFactor
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = self.destinationAlphaBlendFactor

		return try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
	}()

	lazy var colorSamplerState: MTLSamplerState = {
		let samplerDescriptor = MTLSamplerDescriptor()
		samplerDescriptor.minFilter = .nearest
		samplerDescriptor.magFilter = .linear
		samplerDescriptor.sAddressMode = .repeat
		samplerDescriptor.tAddressMode = .repeat
		return self.device.makeSamplerState(descriptor: samplerDescriptor)
	}()

	func vertexBuffer(for vertices: [Vertex]) -> VertexBuffer<Vertex>? {
		return VertexBuffer<Vertex>(device: device, vertices: vertices)
	}

	func vertexBuffer(for rect: Rect) -> VertexBuffer<Vertex>? {
		return VertexBuffer<Vertex>(device: device, vertices: self.vertices(for: rect))
	}
	
	func texture(of image: XImage) -> MTLTexture? {
		guard let cgImage: CGImage = image.cgImage else { return nil }
		var options: [String : NSObject] = [MTKTextureLoaderOptionSRGB: false as NSNumber]
		if #available(iOS 10.0, *) {
			options[MTKTextureLoaderOptionOrigin] = true as NSNumber
		}
		return try? device.textureLoader.newTexture(with: cgImage, options: options)
	}
	
	// MARK: -

	func renderImage(context: RenderContext, texture: MTLTexture, vertexBuffer: VertexBuffer<Vertex>) {
		let transform = context.transform
		var uniforms = Uniforms(transform: transform)
		let uniformsBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: MTLResourceOptions())
		
		let commandBuffer = context.makeCommandBuffer()
		let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: context.renderPassDescriptor)
		
		encoder.setRenderPipelineState(self.renderPipelineState)

		encoder.setFrontFacing(.clockwise)
//		commandEncoder.setCullMode(.back)
		encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, at: 0)
		encoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 1)

		encoder.setFragmentTexture(texture, at: 0)
		encoder.setFragmentSamplerState(self.colorSamplerState, at: 0)

		encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexBuffer.count)

		encoder.endEncoding()
		commandBuffer.commit()
	}

	func renderImage(context: RenderContext, texture: MTLTexture, in rect: Rect) {
		guard let vertexBuffer = self.vertexBuffer(for: rect) else { return }
		self.renderImage(context: context, texture: texture, vertexBuffer: vertexBuffer)
	}
}



