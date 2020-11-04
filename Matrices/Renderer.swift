//
/**
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  var pipelineState: MTLRenderPipelineState!
  
  var timer: Float = 0
  var uniforms = Uniforms()
	var rects: [Rect] = []
	var vertices : [Vertex] = []
	var screenSize: vector_float2 = .zero
  
  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device
        
    let library = device.makeDefaultLibrary()
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction = library?.makeFunction(name: "fragment_main")
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    super.init()
    metalView.clearColor = MTLClearColor(
			red: 1.0,
			green: 1.0,
			blue: 0.8,
			alpha: 1.0
		)
    metalView.delegate = self
    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
  }
	
	func addRectangle(style: RectangleStyle) {
		switch style {
		case .fill:
			let rect = ShapeGenerator.makeFilledRect(
				center: CGPoint(x: 0, y: 0),
				size: CGSize(width: CGFloat(screenSize.x / 3), height: CGFloat(screenSize.x / 3))
			)
			rects.append(rect)
			vertices.append(contentsOf: rect.vertices)
		case .outline:
			let rect = ShapeGenerator.makeOutlinedRect(
				center: CGPoint(x: 0, y: 0),
				size: CGSize(width: CGFloat(screenSize.x / 3), height: CGFloat(screenSize.x / 3))
			)
			rects.append(rect)
			vertices.append(contentsOf: rect.vertices)
		}
	}
	
	func clear() {
		rects = []
		vertices = []
	}
	
	func translation() {
		let matrix = float4x4(translation: float3(10, 0, 0))
		vertices = vertices.map {
			let result = matrix * float4($0.position.x, $0.position.y, 0, 1)
			return Vertex(position: vector_float2(result.x, result.y))
		}
	}
	
	func rotate() {
		let matrix = float4x4(rotationZ: 5)
		vertices = vertices.map {
			let result = matrix * float4($0.position.x, $0.position.y, 0, 1)
			return Vertex(position: vector_float2(result.x, result.y))
		}
	}
	
	func scale() {
		let matrix = float4x4(scaling: float3(1.1, 1.1, 1.1))
		vertices = vertices.map {
			let result = matrix * float4($0.position.x, $0.position.y, 0, 1)
			return Vertex(position: vector_float2(result.x, result.y))
		}
	}
	
	enum RectangleStyle {
		case outline
		case fill
	}
		
	struct ShapeGenerator {
		static func makeOutlinedRect(center: CGPoint, size: CGSize) -> OutlinedRect {
			let centerX = Float(center.x)
			let centerY = Float(center.y)
			let width = Float(size.width)
			let height = Float(size.height)
			
			return OutlinedRect(vertices: [
				Vertex(position: vector_float2(centerX - width / 2, centerY - height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY - height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX - width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX - width / 2, centerY - height / 2)),
			])
		}
		
		static func makeFilledRect(center: CGPoint, size: CGSize) -> FilledRect {
			let centerX = Float(center.x)
			let centerY = Float(center.y)
			let width = Float(size.width)
			let height = Float(size.height)
			
			return FilledRect(vertices: [
				Vertex(position: vector_float2(centerX - width / 2, centerY - height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY - height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX - width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX - width / 2, centerY - height / 2)),
			])
		}
	}
}

protocol Rect {
	var vertices: [Vertex] { get }
}

struct FilledRect: Rect {
	let vertices: [Vertex]
}

struct OutlinedRect: Rect {
	let vertices: [Vertex]
}

extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		screenSize.x = Float(size.width)
		screenSize.y = Float(size.height)
  }
  
  func draw(in view: MTKView) {
    guard
      let descriptor = view.currentRenderPassDescriptor,
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let renderEncoder =
      commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
        return
    }
		renderEncoder.setVertexBytes(
			&screenSize,
			length: MemoryLayout<vector_float2>.stride,
			index: 1
		)

		renderEncoder.setVertexBytes(
			vertices,
			length: MemoryLayout<Vertex>.stride * vertices.count,
			index: 0
		)
		
    renderEncoder.setRenderPipelineState(pipelineState)
		
		
		var vertexCount = 0
		if rects.count > 0 {
			rects.forEach { rect in
				renderEncoder.drawPrimitives(
					type: rect is FilledRect ? .triangle : .lineStrip,
					vertexStart: vertexCount,
					vertexCount: rect.vertices.count
				)
				vertexCount += rect.vertices.count
			}
		}

    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
