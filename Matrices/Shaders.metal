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


#include <metal_stdlib>
using namespace metal;
#import "Common.h"

vertex float4 vertex_main(uint vertexID [[vertex_id]],
													constant Vertex *vertices [[buffer(0)]],
													constant vector_float2 *screenSizePointer [[buffer(1)]]
													)
{
	float2 pixelSpacePosition = vertices[vertexID].position.xy;
	vector_float2 screenSize = vector_float2(*screenSizePointer);

	
	vector_float4 position = vector_float4(0.0, 0.0, 0.0, 1.0);
	position.x = pixelSpacePosition.x - (screenSize.x / 2.0);
	position.y = pixelSpacePosition.y - (screenSize.y / 2.0);
	
	position.xy = pixelSpacePosition / (screenSize / 2.0);

	return vector_float4(position.xy, 1, 1);
}

fragment float4 fragment_main() {
  return float4(0, 0, 0, 1);
}

