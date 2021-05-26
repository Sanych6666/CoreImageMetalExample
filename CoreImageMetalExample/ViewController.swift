//
//  ViewController.swift
//  CoreImageMetalExample
//
//  Created by Alexander Maruk on 25.05.21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var metalView: MetalView!
    
    private var imagePickerController: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func choosePhotoButtonAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
            self.imagePickerController = imagePicker
        }
    }
    
    @IBAction private func useExampleButtonAction(_ sender: Any) {
        if let image = UIImage(named: "exampleImage.png") {
            setMetalView(image: image)
        }
    }
    
    private func setMetalView(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Can't get cgImage")
            return
        }
        let ciImage = CIImage(cgImage: cgImage).oriented(CGImagePropertyOrientation(image.imageOrientation))
        metalView.image = ciImage
        metalView.drawableSize = ciImage.extent.size
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var pickedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            pickedImage = editedImage
        } else {
            pickedImage = info[.originalImage] as? UIImage
        }
        guard let image = pickedImage else {
            print("Expected image, but get following: \(info)")
            return
        }
        imagePickerController?.dismiss(animated: true)
        setMetalView(image: image)
    }
    
}

extension ViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return metalView
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}

