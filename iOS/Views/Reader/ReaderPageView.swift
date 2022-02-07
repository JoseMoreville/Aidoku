//
//  ReaderPageView.swift
//  Aidoku (iOS)
//
//  Created by Skitty on 2/7/22.
//

import UIKit
import Kingfisher

class ReaderPageView: UIView {
    
    var zoomableView = ZoomableScrollView(frame: .zero)
    let imageView = UIImageView()
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var imageViewHeightConstraint: NSLayoutConstraint?
    
    var currentUrl: String?
    
    init() {
        super.init(frame: .zero)
        configureViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        zoomableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomableView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        zoomableView.addSubview(imageView)
        
        zoomableView.zoomView = imageView
        
        activateConstraints()
    }
    
    func activateConstraints() {
        zoomableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        zoomableView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: zoomableView.widthAnchor).isActive = true
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
        imageViewHeightConstraint?.isActive = true
        imageView.centerXAnchor.constraint(equalTo: zoomableView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: zoomableView.centerYAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func updateZoomBounds() {
        var height = (self.imageView.image?.size.height ?? 0) / (self.imageView.image?.size.width ?? 1) * self.imageView.bounds.width
        if height > zoomableView.bounds.height {
            height = zoomableView.bounds.height
        }
        self.imageViewHeightConstraint?.constant = height
        self.zoomableView.contentSize = self.imageView.bounds.size
    }
    
    func setPageImage(url: String) {
        guard currentUrl != url else { return }
        currentUrl = url
        
        DispatchQueue.main.async {
            let processor = DownsamplingImageProcessor(size: self.bounds.size)
            let retry = DelayRetryStrategy(maxRetryCount: 5, retryInterval: .seconds(0.5))
            self.imageView.kf.setImage(
                with: URL(string: url),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.3)),
                    .retryStrategy(retry)
                ]
            ) { result in
                switch result {
                case .success:
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.updateZoomBounds()
                default:
                    // TODO: maybe do something here?
                    break
                }
            }
        }
    }
}