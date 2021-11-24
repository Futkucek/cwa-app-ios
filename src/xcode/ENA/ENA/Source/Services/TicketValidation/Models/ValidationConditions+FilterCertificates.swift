//
// 🦠 Corona-Warn-App
//

import Foundation

extension ValidationConditions {
	static let pcrTypeString = "LP6464-4"
	static let antigenTypeString = "LP217198-3"

	func filterCertificates(healthCertifiedPersons: [HealthCertifiedPerson]) -> (supportedHealthCertificates: [HealthCertificate], supportedCertificateTypes: [String]) {
		var supportedHealthCertificates: [HealthCertificate] = []
		var supportedCertificateTypes: [String] = []

		// all certificates of all persons
		let allCertificates = healthCertifiedPersons.flatMap { $0.healthCertificates }
		
		// certificates that matches person's validation conditions
		let healthCertifiedPersonCertificates = allCertificates.filter({
			$0.name.standardizedGivenName == self.gnt &&
			$0.name.standardizedFamilyName == self.fnt &&
			$0.dateOfBirth == self.dob
		})
		
		if let certificateTypes = self.type, !certificateTypes.isEmpty {
			// if type contains v, all Vaccination Certificates shall pass the filter
			if certificateTypes.contains("v") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.vaccinationEntry != nil })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate)
			}
			// if type contains r, all Recovery Certificates shall pass the filter
			if certificateTypes.contains("r") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.recoveryEntry != nil })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate)
			}
			// if type contains t, all Test Certificates shall pass the filter
			if certificateTypes.contains("t") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.testEntry != nil })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.testCertificate)
			}
			// if type contains tp, all PCR tests shall pass the filter
			if certificateTypes.contains("tp") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.testEntry != nil && $0.testEntry?.typeOfTest == ValidationConditions.pcrTypeString })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.pcrTestCertificate)
			}
			// if type contains tr, all RAT tests shall pass the filter
			if certificateTypes.contains("tr") {
				supportedHealthCertificates.append(contentsOf: healthCertifiedPersonCertificates.filter { $0.testEntry != nil && $0.testEntry?.typeOfTest == ValidationConditions.antigenTypeString })
				supportedCertificateTypes.append(AppStrings.TicketValidation.SupportedCertificateType.ratTestCertificate)
			}
		} else {
			// if type is nil or empty, then there is no filtering by type
			supportedHealthCertificates = healthCertifiedPersonCertificates
		}
		
		// sorting on the basis of certificate type
		supportedHealthCertificates = supportedHealthCertificates.sorted(by: >)
		
		return (supportedHealthCertificates, supportedCertificateTypes)
	}
}
