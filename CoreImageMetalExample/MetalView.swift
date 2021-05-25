//
//  MetalView.swift
//  CoreImageMetalExample
//
//  Created by Alexander Maruk on 25.05.21.
//

import Foundation
import MetalKit

class MetalView: MTKView {
    
    var image: CIImage?
    private let defaultDevice = MTLCreateSystemDefaultDevice()!
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private var context: CIContext!
    private var commandQueue: MTLCommandQueue!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero, device: defaultDevice)
        commonInit()
    }
    
    private func commonInit() {
        device = defaultDevice
        translatesAutoresizingMaskIntoConstraints = false
        framebufferOnly = false
        isPaused = true
        delegate = self
        
        context = CIContext(mtlDevice: defaultDevice, options: [
            .name: "CoreImageMetalExample_MetalView",
            .workingColorSpace : colorSpace,
            .outputColorSpace : colorSpace
        ])
        
        commandQueue = defaultDevice.makeCommandQueue()
    }
    
    override func draw() {
        super.draw()
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
    }
}


extension MetalView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        autoreleasepool {
            guard let drawable = currentDrawable, let image = self.image else {
                return
            }
            
            let destination = CIRenderDestination(width: Int(image.extent.width),
                                                  height: Int(image.extent.height),
                                                  pixelFormat: colorPixelFormat,
                                                  commandBuffer: nil,
                                                  mtlTextureProvider: { () -> MTLTexture in
                                                    return drawable.texture
                                                  })
            
            _ = try? context?.startTask(toRender: image, to: destination)
            
            guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                return
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
        
    }
    
}
