//
//  ViewController.swift
//  CoreImageMetalExample
//
//  Created by Alexander Maruk on 25.05.21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var metalView: MetalView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var metalViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var metalViewHeightConstraint: NSLayoutConstraint!
    
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
    
    private func setMetalView(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Can't get cgImage")
            return
        }
        let ciImage = CIImage(cgImage: cgImage).oriented(CGImagePropertyOrientation(image.imageOrientation))
        metalView.image = ciImage
        setupScrollViewContent(size: ciImage.extent.size)
        metalView.drawableSize = ciImage.extent.size
    }
    
    private func setupScrollViewContent(size: CGSize) {
        let minScale = min(scrollView.frame.height / size.height, scrollView.frame.width / size.width)
        let maxScale: CGFloat = 10
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale < 1.0 ? maxScale : minScale * maxScale
        scrollView.zoomScale = minScale
        metalViewWidthConstraint.constant = size.width
        metalViewHeightConstraint.constant = size.height
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

