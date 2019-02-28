
//
//  ProfileViewController.swift
//  AirbnbClone
//
//  Created by Oniel Rosario on 2/16/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    private var usersession: UserSession!
     private var storagemanager: StorageManager!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var newPost: UIButton!
    private var profileImage: UIImage! {
        didSet {
            self.profileTableView.reloadData()
        }
    }
    private var name: String!
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.allowsEditing = true
        ip.delegate = self
        return ip
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        usersession = (UIApplication.shared.delegate as! AppDelegate).usersession
        storagemanager = (UIApplication.shared.delegate as! AppDelegate).storageManager
        profileTableView.dataSource = self
        profileTableView.delegate = self
        usersession.usersessionSignOutDelegate = self
        storagemanager.delegate = self
        updateImage()
    
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateImage()
    }
    
    @IBAction func newPostButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let postVC = storyboard.instantiateViewController(withIdentifier: "NewPostVC") as? NewPostController else { return }
       navigationController?.pushViewController(postVC, animated: true)
    }
    
    private func updateImage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let activity = storyboard.instantiateViewController(withIdentifier: "ActivityVC") as! ActivityViewController
    
        let user = usersession.getCurrentUser()
        if user != nil {
            if let image = ImageCache.shared.fetchImageFromCache(urlString: user?.photoURL?.absoluteString ?? "no photo") {
              self.profileImage = image
                self.name = user?.email
            } else {
                activity.modalPresentationStyle = .overCurrentContext
                present(activity, animated: true, completion: nil)
                ImageCache.shared.fetchImageFromNetwork(urlString: user?.photoURL?.absoluteString ?? "no photo") { (error, image) in
                    if let error = error {
                        print(error)
                    } else if let image = image {
                      self.profileImage = image
                        self.name = user?.email
                        activity.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
           print("no user logged in")
        }
    }
    
    @objc func imagepicker(sender: UIButton) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.sourceType = .camera
            self.showImagePickerController()
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePickerController.sourceType = .photoLibrary
            self.showImagePickerController()
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
        return alertController
    }
    
    private func showImagePickerController() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        usersession.signOut()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? ProfileTableViewCell else { return UITableViewCell() }
        cell.profilePicture.setImage(profileImage, for: .normal)
        cell.profileName.text = name
        cell.delegate = self
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? ProfileTableViewCell else { return }
        cell.profilePicture.addTarget(self, action: #selector(imagepicker), for: .touchUpInside)
    }
}

extension ProfileViewController: UserSessionSignOutDelegate {
    func didRecieveSignOutError(_ usersession: UserSession, error: Error) {
        showAlert(title: "Error signing out", message: error.localizedDescription, actionTitle: "OK")
    }
    
    func didSignOutUser(_ usersession: UserSession) {
        presentViewController()
    }
    
    private func presentViewController() {
        if let _ = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UITabBarController {
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
         let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            window?.rootViewController = loginVC
        } else {
            dismiss(animated: true)
        }
    }
}

extension ProfileViewController: StorageManagerDelegate {
    func didFetchImage(_ storageManager: StorageManager, imageURL: URL) {
        usersession.updateUser(displayName: nil, photoURL: imageURL)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalPhoto = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            showAlert(title: "Error with image", message: "try again", actionTitle: "OK")
            return
        }
        
        profileImage = originalPhoto
//        newPost.setImage(profileImage, for: .normal)
        guard let imageData = originalPhoto.jpegData(compressionQuality: 1.0) else {
            print("failed to create image data")
            return
        }
        storagemanager.postImage(withData: imageData)
        dismiss(animated: true)
    }
}

extension ProfileViewController: SenderButtonDelegate {
    func sender() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.sourceType = .camera
            self.showImagePickerController()
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePickerController.sourceType = .photoLibrary
            self.showImagePickerController()
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    
}
