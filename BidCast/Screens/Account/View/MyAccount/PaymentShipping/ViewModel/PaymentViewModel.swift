import Foundation

@MainActor
final class PaymentViewModel: ObservableObject {
    
    @Published var cardDict = ResponseModel<CardModel>()
  
    @Published var getAddressDict = ResponseModel<[AddressModel]>()
    @Published var addressDict = ResponseModel<AddressModel>()
    @Published var errorMessage: String? = nil

    

    // MARK: - Get Cards
    func getCard() async {
        do {
            if let response: ResponseModel<CardModel> = try await APIManager.shared.request(
                type: APIEndPoint.getCard,
                header: true
            ) {
                self.cardDict = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Delete Card
    func deleteCard(parameters: DeleteCardRequest) async {
        do {
            if let response: ResponseModel<CardModel>  = try await APIManager.shared.request(
                type: APIEndPoint.deleteCard(param: parameters),
                header: true
            ) {
                await getCard()
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Addresses
    func getAddresses() async {
        do {
            if let response: ResponseModel<[AddressModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getAddress,
                header: true
            ) {
                self.getAddressDict = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Set Default Address
    func setDefaultAddress(parameters: AddressDefaultParam) async {
        do {
            if let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.setDefaultAddress(param: parameters),
                header: true
            ) {
                self.addressDict = response
            }
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Set Default Address
    func setDefaultCard(parameters: CardDefaultRequest) async {
        do {
            if let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.setDefaultCard(param: parameters),
                header: true
            ) {
                self.addressDict = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Delete Address
    func deleteAddress(parameters: AddressDefaultParam) async {
        do {
            if let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteAddress(param: parameters),
                header: true
            ){
                await getAddresses()
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        if let dataError = error as? DataError {
            switch dataError {
            case .invalidCode(let message):
                self.errorMessage = message ?? "Invalid code error"
            case .invalidResponse(let data):
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.errorMessage = "Invalid response: \(json)"
                } else {
                    self.errorMessage = "Invalid response with no data"
                }
            default:
                self.errorMessage = error.localizedDescription
            }
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}
