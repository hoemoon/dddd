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

class ViewController: LocalViewController {
  
  var renderer: Renderer?
	
	lazy var addOutlinedRectButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(didTapAddOutlinedRectButton(_:)), for: .touchDown)
		button.setTitle("add outlined rectangle", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	lazy var addFilledRectButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(didTapAddFilledRectButton(_:)), for: .touchDown)
		button.setTitle("add filled rectangle", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	lazy var clearButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(didTapClear(_:)), for: .touchDown)
		button.setTitle("clear", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	lazy var moveButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(didTapMoveButton(_:)), for: .touchDown)
		button.setTitle("move", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	lazy var rotateButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(didTapRotateButton(_:)), for: .touchDown)
		button.setTitle("rotate", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()

	lazy var scaleButton: UIButton = {
		let button = UIButton(type: .custom)
		button.addTarget(self, action: #selector(didTapScaleButton(_:)), for: .touchDown)
		button.setTitle("scale", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()


	lazy var stackView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [
			addOutlinedRectButton,
			addFilledRectButton,
			clearButton,
			moveButton,
			rotateButton,
			scaleButton
		])
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		return view
	}()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let metalView = view as? MTKView else {
      fatalError("metal view not set up in storyboard")
    }
    renderer = Renderer(metalView: metalView)
		
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
			view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
		])
  }
	
	@objc func didTapAddOutlinedRectButton(_ button: UIButton) {
		renderer?.addRectangle(style: .outline)
	}
	
	@objc func didTapAddFilledRectButton(_ button: UIButton) {
		renderer?.addRectangle(style: .fill)
	}
	
	@objc func didTapClear(_ button: UIButton) {
		renderer?.clear()
	}
	
	@objc func didTapMoveButton(_ button: UIButton) {
		renderer?.translation()
	}
	
	@objc func didTapRotateButton(_ button: UIButton) {
		renderer?.rotate()
	}
	
	@objc func didTapScaleButton(_ button: UIButton) {
		renderer?.scale()
	}
}
