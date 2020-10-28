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
  var mesh: MTKMesh!
  var vertexBuffer: MTLBuffer!
  var pipelineState: MTLRenderPipelineState!
  
  var timer: Float = 0
  var uniforms = Uniforms()
	var outlinedRectangles: [Vertex] = []
  
  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device
    
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    
    vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
    let meshDescriptor =
      MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
    (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
    
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
		outlinedRectangles.append(contentsOf: ShapeGenerator.makeRect(center: .zero, size: CGSize(width: 0.5, height: 0.5)))
	}
	
	enum RectangleStyle {
		case outline
		case fill
	}
	
	struct ShapeGenerator {
		static func makeRect(center: CGPoint, size: CGSize) -> [Vertex] {
			let centerX = Float(center.x)
			let centerY = Float(center.y)
			let width = Float(size.width)
			let height = Float(size.height)
			
			return [
				Vertex(position: vector_float2(centerX - width / 2, centerY - height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY - height / 2)),
				Vertex(position: vector_float2(centerX + width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX - width / 2, centerY + height / 2)),
				Vertex(position: vector_float2(centerX - width / 2, centerY - height / 2)),
			]
		}
	}
}

extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
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
			outlinedRectangles,
			length: MemoryLayout<Vertex>.stride * outlinedRectangles.count,
			index: 0
		)
		
    renderEncoder.setRenderPipelineState(pipelineState)
		if outlinedRectangles.count > 0 {
			renderEncoder.drawPrimitives(
				type: .lineStrip,
				vertexStart: 0,
				vertexCount: outlinedRectangles.count
			)
		}
    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
