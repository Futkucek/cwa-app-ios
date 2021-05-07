////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewDayTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellViewModel: DiaryOverviewDayCellModel) {
		dateLabel.text = cellViewModel.formattedDate

		exposureHistoryStackView.isHidden = cellViewModel.hideExposureHistory
		exposureHistoryNoticeImageView.image = cellViewModel.exposureHistoryImage
		exposureHistoryTitleLabel.text = cellViewModel.exposureHistoryTitle
		exposureHistoryTitleLabel.accessibilityIdentifier = cellViewModel.exposureHistoryAccessibilityIdentifier
		exposureHistoryDetailLabel.text = cellViewModel.exposureHistoryDetail
		exposureHistoryTitleLabel.style = .body
		exposureHistoryDetailLabel.style = .subheadline
		exposureHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)

		// Check-Ins with risk
		checkinHistoryStackView.isHidden = cellViewModel.hideCheckinRisk
		checkinHistoryNoticeImageView.image = cellViewModel.checkinImage
		checkinHistoryTitleLabel.text = cellViewModel.checkinTitleHeadlineText
		checkinHistoryTitleLabel.accessibilityIdentifier = cellViewModel.checkinTitleAccessibilityIdentifier
		checkinHistoryTitleLabel.style = .body
		checkinHistoryDetailLabel.text = cellViewModel.checkinDetailDescription
		checkinHistoryDetailLabel.style = .subheadline
		checkinHistoryDetailLabel.textColor = .enaColor(for: .textPrimary2)
		
		checkinsWithRiskStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		cellViewModel.checkinsWithRisk.enumerated().forEach { index, riskyCheckin in
			let checkInLabel = ENALabel()
			checkInLabel.adjustsFontForContentSizeCategory = true
			checkInLabel.numberOfLines = 0
			checkInLabel.style = .subheadline
			checkInLabel.textColor = .enaColor(for: .textPrimary2)
			let riskColor = cellViewModel.colorFor(riskLevel: riskyCheckin.risk)
			let eventName = cellViewModel.checkInDespription(checkinWithRisk: riskyCheckin)
			let checkinName = NSAttributedString(string: eventName).bulletPointString(bulletPointFont: .enaFont(for: .title2, weight: .bold, italic: false), bulletPointColor: riskColor)
			
			checkInLabel.attributedText = checkinName
			checkInLabel.isAccessibilityElement = true
			checkInLabel.accessibilityIdentifier = "CheckinWithRisk\(index)"
			checkinsWithRiskStackView.addArrangedSubview(checkInLabel)
		}
		
		encountersVisitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		cellViewModel.selectedEntries.enumerated().forEach { index, entry in
			let imageView = UIImageView()
			NSLayoutConstraint.activate([
				imageView.widthAnchor.constraint(equalToConstant: 32),
				imageView.heightAnchor.constraint(equalToConstant: 32)
			])

			let entryLabel = ENALabel()
			entryLabel.adjustsFontForContentSizeCategory = true
			entryLabel.style = .body

			let entryDetailLabel = ENALabel()
			entryDetailLabel.adjustsFontForContentSizeCategory = true
			entryDetailLabel.numberOfLines = 0
			entryDetailLabel.style = .body
			entryDetailLabel.textColor = .enaColor(for: .textPrimary2)

			let entryCircumstancesLabel = ENALabel()
			entryCircumstancesLabel.adjustsFontForContentSizeCategory = true
			entryCircumstancesLabel.numberOfLines = 0
			entryCircumstancesLabel.font = .enaFont(for: .body, italic: true)
			entryCircumstancesLabel.textColor = .enaColor(for: .textPrimary2)

			let entryLabelStackView = UIStackView()
			entryLabelStackView.translatesAutoresizingMaskIntoConstraints = false
			entryLabelStackView.axis = .vertical

			entryLabelStackView.addArrangedSubview(entryLabel)

			switch entry {
			case .contactPerson(let contactPerson):
				imageView.image = UIImage(named: "Icons_Diary_ContactPerson")
				entryLabel.text = contactPerson.name
				entryLabel.accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.person, index)

				if let personEncounter = contactPerson.encounter {
					let detailLabelText = cellViewModel.entryDetailTextFor(personEncounter: personEncounter)
					if detailLabelText != "" {
						entryDetailLabel.text = detailLabelText
						entryLabelStackView.addArrangedSubview(entryDetailLabel)
					}

					if personEncounter.circumstances != "" {
						entryCircumstancesLabel.text = personEncounter.circumstances
						entryLabelStackView.addArrangedSubview(entryCircumstancesLabel)
					}
				}

			case .location(let location):
				imageView.image = UIImage(named: "Icons_Diary_Location")
				entryLabel.text = location.name
				entryLabel.accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.location, index)

				if let locationVisit = location.visit {
					let detailLabelText = cellViewModel.entryDetailTextFor(locationVisit: locationVisit)

					if detailLabelText != "" {
						entryDetailLabel.text = detailLabelText
						entryLabelStackView.addArrangedSubview(entryDetailLabel)
					}

					if locationVisit.circumstances != "" {
						entryCircumstancesLabel.text = locationVisit.circumstances
						entryLabelStackView.addArrangedSubview(entryCircumstancesLabel)
					}
				}
			}

			let entryStackView = UIStackView()
			entryStackView.axis = .horizontal
			entryStackView.spacing = 15
			entryStackView.alignment = .center

			entryStackView.addArrangedSubview(imageView)
			entryStackView.addArrangedSubview(entryLabelStackView)

			encountersVisitsStackView.addArrangedSubview(entryStackView)
		}

		encountersVisitsContainerStackView.isHidden = encountersVisitsStackView.arrangedSubviews.isEmpty

		accessibilityTraits = [.button]
		accessibilityIdentifier = String(format: AccessibilityIdentifiers.ContactDiaryInformation.Overview.cell, cellViewModel.accessibilityIdentifierIndex)
	}

	// MARK: - Private

	@IBOutlet private weak var dateLabel: ENALabel!
	@IBOutlet private weak var encountersVisitsContainerStackView: UIStackView!
	@IBOutlet private weak var encountersVisitsStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryStackView: UIStackView!
	@IBOutlet private weak var exposureHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var exposureHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var exposureHistoryDetailLabel: ENALabel!
	
	// Check-Ins with risk
	@IBOutlet private weak var checkinHistoryStackView: UIStackView!
	@IBOutlet private weak var checkinHistoryNoticeImageView: UIImageView!
	@IBOutlet private weak var checkinHistoryTitleLabel: ENALabel!
	@IBOutlet private weak var checkinHistoryDetailLabel: ENALabel!
	@IBOutlet private weak var checkinsWithRiskStackView: UIStackView!
}
