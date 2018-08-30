//
//  TrainStopTableViewCell.swift
//  GroebeCTA
//
//  Created by Sean Groebe on 5/11/18.
//  Copyright © 2018 DePaul University. All rights reserved.
//

import UIKit

class TrainStopTableViewCell: UITableViewCell {

	@IBOutlet weak var stopNameLabel: UILabel!
	@IBOutlet weak var destinationNameLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	
	@IBOutlet weak var arrivalLabel: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
