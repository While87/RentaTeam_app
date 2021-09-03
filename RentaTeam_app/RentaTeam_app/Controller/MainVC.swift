//
//  MainVC.swift
//  RentaTeam_app
//
//  Created by Vladimir Gorbunov on 02.09.2021.
//

import UIKit
import RealmSwift

class MainVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIButton!
    
    let realm = try! Realm()
    var imageItems: Results<ImageRM>?
    var notifications: NotificationToken?
    
    let manager = MainManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageItems = realm.objects(ImageRM.self)
        initIndicator()
              
        manager.reloadEmptyImages()
        manager.getNewGalleryItems()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Register custom collection cell
        self.collectionView.register(UINib(nibName: "CustomCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")
        
        realmObserver()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func realmObserver() {
        notifications = imageItems?.observe() { [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
               break
            case .update:
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    func initIndicator() {
        indicator.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        indicator.layer.cornerRadius = 20
        indicator.layer.borderWidth = 1
        indicator.layer.borderColor = UIColor(named: "border")?.cgColor
        indicator.backgroundColor = UIColor(named: "background")
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -15).isActive = true
        indicator.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 15).isActive = true
        
        guard imageItems?.count != nil, imageItems!.count > 0 else {
            indicator.setTitle("0 / 0", for: .normal)
            return
        }
        indicator.setTitle("1 / \(imageItems?.count ?? 0)", for: .normal)
    }
}

//MARK: Extension: collectionView protocols

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        if (imageItems![indexPath.item].image != nil) {
            cell.waitIndicator.isHidden = true
            cell.imageCell.image = UIImage(data: imageItems![indexPath.item].image!)
        }
        
        cell.labelCell.text = imageItems![indexPath.item].title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Detail", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        guard let image = UIImage(data: (imageItems?[indexPath.item].image)!) else {return}
        guard let label = imageItems?[indexPath.item].downloadedAt else {return}
        detailVC.updateData(image: image, label: label)
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width - 10, height: self.collectionView.bounds.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            let index = collectionView.indexPath(for: cell)?.item
            indicator.setTitle("\(index! + 1) / \(imageItems?.count ?? 0)", for: .normal)
            if index! > (imageItems!.count - 10) {
                manager.reloadEmptyImages()
                manager.getNewGalleryItems()
            }
        }
    }
}
