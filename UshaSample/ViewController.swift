//
//  ViewController.swift
//  UshaSample
//
//  Created by Don Mag on 2/22/21.
//

import UIKit

struct SampleStruct {
	var picName: String = ""
	var picDate: String = ""
	var picDesc: String = ""
	var picCopy: String = ""
	var picURL: String = ""
}

class ViewController: UITableViewController {

	var myData: [SampleStruct] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var ss: SampleStruct!
		
		// this would likely come from a remote server, but
		//	let's create two sample items
		
		ss = SampleStruct(picName: "NGC 247 and Friends",
						  picDate: "2020 January 16",
						  picDesc: "Very large image - be patient...\nAbout 70,000 light-years across, NGC 247 is a spiral galaxy smaller than our Milky Way. Measured to be only 11 million light-years distant it is nearby though. Tilted nearly edge-on as seen from our perspective, it dominates this telescopic field of view toward the southern constellation Cetus. The pronounced void on one side of the galaxy's disk recalls for some its popular name, the Needle's Eye galaxy. Many background galaxies are visible in this sharp galaxy portrait, including the remarkable string of four galaxies just below and left of NGC 247 known as Burbidge's Chain. Burbidge's Chain galaxies are about 300 million light-years distant. NGC 247 itself is part of the Sculptor Group of galaxies along with the shiny spiral NGC 253.",
						  picCopy: "Acquisition - Eric Benson, Processing - Dietmar Hager",
						  picURL: "https://apod.nasa.gov/apod/image/2001/NGC247hager.jpg")
		
		myData.append(ss)
		
		ss = SampleStruct(picName: "An Almost Eclipse of the Moon",
						  picDate: "2020 January 18",
						  picDesc: "This composited series of images follows the Moon on January 10, the first Full Moon of 2020, in Hungarian skies. The lunar disk is in mid-eclipse at the center of the sequence though. It looks only slightly darker there as it passes through the light outer shadow or penumbra of planet Earth. In fact during this penumbral lunar eclipse the Moon almost crossed into the northern edge of Earth's dark central shadow or umbra. Subtle and hard to see, this penumbral lunar eclipse was the first of four lunar eclipses in 2020, all of which will be penumbral lunar eclipses.",
						  picCopy: "Image Credit & Copyright: Gyorgy Soponyai",
						  picURL: "https://apod.nasa.gov/apod/image/2001/APOD-Soponyai-PenumbralEclipse.jpg")
		
		myData.append(ss)
		
	}
	
	// standard table view controller stuff
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return myData.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = myData[indexPath.row].picName
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// instantiate the "detail" view controller
		if let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? DetailViewController {
			// set its picData
			vc.picData = myData[indexPath.row]
			// push
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
}

class DetailViewController: UIViewController {
	
	@IBOutlet var dateOfThePic: UILabel!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var descLabel: UILabel!
	@IBOutlet var copyrightLabel: UILabel!
	
	var picData: SampleStruct?
	
	private var imageURL: URL!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// make sure we got picture data
		guard let pd = picData else {
			print("Did not get picData!")
			return
		}

		// make sure we have a valid URL for the picture
		guard let imgURL = URL(string: pd.picURL) else {
			print("Invalid image URL!")
			return
		}
		
		self.title = pd.picName

		imageURL = imgURL
		
		dateOfThePic.text = pd.picDate
		descLabel.text = pd.picDesc
		copyrightLabel.text = pd.picCopy
		
		// add an Activity spinner
		let v = UIActivityIndicatorView()
		v.style = .large
		v.color = .white
		
		// add a "Loading" label
		let lbl = UILabel()
		lbl.text = "Loading picture..."
		lbl.textColor = .white
		
		// add them to the image view
		imageView.addSubview(v)
		imageView.addSubview(lbl)
		v.translatesAutoresizingMaskIntoConstraints = false
		lbl.translatesAutoresizingMaskIntoConstraints = false
		// centered in the image view
		NSLayoutConstraint.activate([
			v.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
			v.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
			lbl.topAnchor.constraint(equalTo: v.bottomAnchor, constant: 8.0),
			lbl.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
		])
		
		// start spinning
		v.startAnimating()

		// start async image download
		loadPicture(url: imageURL)
	}
	
	func loadPicture(url: URL) {
		DispatchQueue.global().async { [weak self] in
			if let data = try? Data(contentsOf: url) {
				if let image = UIImage(data: data) {
					DispatchQueue.main.async {
						self?.imageWasDownloaded(image)
					}
				}
			}
		}
	}
	
	func imageWasDownloaded(_ img: UIImage) -> Void {

		// remove spinner and loading label
		imageView.subviews.forEach {
			$0.removeFromSuperview()
		}
		
		// set the image
		imageView.image = img
		
		// get the aspect ratio
		let m = img.size.height / img.size.width
		// add new aspect ratio constraint to the image view
		self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: m).isActive = true
		// animate the size change
		UIView.animate(withDuration: 0.3, animations: { [weak self] in
			guard let self = self else { return }
			self.view.layoutIfNeeded()
		})
		
	}

}
