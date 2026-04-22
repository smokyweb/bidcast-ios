//  PaymentModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - GetPaymentCardsResponse.kt
//    - CheckKycResponse.kt
//    - GetKYCDetailsRespnse.kt
//    - FetchSellerVerificationResponse.kt
//    - StoreSellerIdResponse.kt
//    - StorePhoneNumberResponse.kt
//    - GetBuyerIdentityResponse.kt
//    - PayoutHistoryResponse.kt
//    - WalletInfoResponse.kt
//    - GetTransactionsHistoryResponse.kt
//    - (promo code verification, shipping card add)

import Foundation

// MARK: - GetPaymentCardsResponse (GET api/get-card)

/// QA-NOTE: Paginated but Android uses `current_page` / `per_page` /
/// `total_pages` / `total_records` — different from `APIPaginatedResponse`.
struct GetPaymentCardsResponse: Codable {
    let status: String?
    let message: String?
    let currentPage: Int?
    let perPage: Int?
    let totalPages: Int?
    let totalRecords: Int?
    let data: [PaymentCard?]?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case currentPage = "current_page"
        case perPage = "per_page"
        case totalPages = "total_pages"
        case totalRecords = "total_records"
    }
}

struct PaymentCard: Codable, Identifiable, Hashable {
    let cardId: String?
    let cardHolderName: String?
    let expMonth: Int?
    let expYear: Int?
    let fingerprint: String?
    let isDefault: Bool?
    let last4: String?

    var id: String { cardId ?? UUID().uuidString }

    enum CodingKeys: String, CodingKey {
        case fingerprint, last4
        case cardId = "card_id"
        case cardHolderName = "card_holder_name"
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case isDefault = "is_default"
    }
}

// MARK: - AddPaymentCardRequest (POST api/add-card)

struct AddPaymentCardRequest: Encodable {
    let cardHolderName: String
    let cardNumber: String
    let expMonth: String
    let expYear: String
    let cvc: String

    enum CodingKeys: String, CodingKey {
        case cvc
        case cardHolderName = "card_holder_name"
        case cardNumber = "card_number"
        case expMonth = "exp_month"
        case expYear = "exp_year"
    }
}

// MARK: - KYC (POST api/stripe/check-Kyc, GET api/stripe/kyc-details)

typealias CheckKycResponse = APIResponse<CheckKycData>

struct CheckKycData: Codable, Hashable {
    let res: Bool?
    let kycStatus: String?
    let kycDetails: KycDetails?
    let expiresAt: Int?
    let created: Int?
    let msg: String?
    let objectX: String?
    let url: String?              // `link` on Android

    enum CodingKeys: String, CodingKey {
        case res, created, msg
        case kycStatus = "kyc_status"
        case kycDetails = "kyc_details"
        case expiresAt = "expires_at"
        case objectX = "object"
        case url = "link"
    }
}

struct KycDetails: Codable, Hashable {
    let accountId: String?
    let bankId: String?
    let city: AnyCodable?
    let country: AnyCodable?
    let currency: String?
    let phone: AnyCodable?
    let postalCode: AnyCodable?
    let routingNumber: String?

    enum CodingKeys: String, CodingKey {
        case currency
        case accountId = "account_id"
        case bankId = "bank_id"
        case city, country, phone
        case postalCode = "postal_code"
        case routingNumber = "rounting_number"   // QA-NOTE: Android typo preserved
    }
}

typealias GetKYCDetailsResponse = APIResponse<GetKYCDetailsData>

struct GetKYCDetailsData: Codable, Hashable {
    let accountId: String?
    let city: AnyCodable?
    let country: AnyCodable?
    let phone: AnyCodable?
    let postalCode: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case city, country, phone
        case accountId = "account_id"
        case postalCode = "postal_code"
    }
}

// MARK: - Seller Identity (KYC gating)

typealias FetchSellerVerificationResponse = APIResponse<SellerVerificationData>

struct SellerVerificationData: Codable, Hashable {
    let id: Int?
    let cardId: String?
    let cardDetails: VerificationCardDetails?
    let idCard: String?
    let image: String?
    let numberOtpVerified: Int?
    let otp: String?
    let phoneNumber: String?
    let reason: String?
    let status: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case id, image, otp, reason, status
        case cardId = "card_id"
        case cardDetails = "card_details"
        case idCard = "id_card"
        case numberOtpVerified = "number_otp_verified"
        case phoneNumber = "phone_number"
        case userId = "user_id"
    }
}

struct VerificationCardDetails: Codable, Hashable {
    let expMonth: Int?
    let expYear: Int?
    let last4: String?

    enum CodingKeys: String, CodingKey {
        case last4
        case expMonth = "exp_month"
        case expYear = "exp_year"
    }
}

typealias StoreSellerIdResponse = APIResponse<StoreSellerIdData>

struct StoreSellerIdData: Codable, Hashable {
    let id: Int?
    let userId: Int?
    let cardId: String?
    let idCard: String?
    let image: String?
    let numberOtpVerified: Int?
    let otp: String?
    let phoneNumber: String?
    let reason: AnyCodable?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, image, otp, reason, status
        case userId = "user_id"
        case cardId = "card_id"
        case idCard = "id_card"
        case numberOtpVerified = "number_otp_verified"
        case phoneNumber = "phone_number"
    }
}

typealias StorePhoneNumberResponse = APIResponse<StorePhoneNumberData>

struct StorePhoneNumberData: Codable, Hashable {
    let otp: Int?
    let phoneNumer: String?           // QA-NOTE: Android typo preserved

    enum CodingKeys: String, CodingKey {
        case otp
        case phoneNumer = "phone_numer"
    }
}

// MARK: - Buyer Identity

typealias GetBuyerIdentityResponse = APIResponse<BuyerIdentityData>

struct BuyerIdentityData: Codable, Hashable {
    let id: Int?
    let image: String?
    let status: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case id, image, status
        case userId = "user_id"
    }
}

// MARK: - Wallet / Payouts / Transactions

typealias WalletInfoResponse = APIResponse<WalletInfoData>

struct WalletInfoData: Codable, Hashable {
    let availableBalance: Double?
    let availableForPayout: Double?
    let processing: Double?

    enum CodingKeys: String, CodingKey {
        case processing
        case availableBalance = "avaiable_balance"          // QA-NOTE: typo preserved
        case availableForPayout = "avaiable_for_payout"     // QA-NOTE: typo preserved
    }
}

typealias PayoutHistoryResponse = APIPaginatedResponse<PayoutEntry>

struct PayoutEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let accountNumber: String?
    let cardNumber: AnyCodable?
    let chargeId: AnyCodable?
    let date: String?
    let discount: Int?
    let orderId: AnyCodable?
    let paymentIntentId: AnyCodable?
    let productPrice: AnyCodable?
    let sellerId: AnyCodable?
    let shippingCharges: Int?
    let sourceType: String?
    let status: String?
    let subTotal: Int?
    let taxAmount: Int?
    let total: Int?
    let type: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case id, date, discount, status, type, total
        case accountNumber = "account_number"
        case cardNumber = "card_number"
        case chargeId = "charge_id"
        case orderId = "order_id"
        case paymentIntentId = "payment_intent_id"
        case productPrice = "product_price"
        case sellerId = "seller_id"
        case shippingCharges = "shipping_charges"
        case sourceType = "source_type"
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case userId = "user_id"
    }
}

typealias GetTransactionsHistoryResponse = APIPaginatedResponse<TransactionEntry>

struct TransactionEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let accountNumber: AnyCodable?
    let buyer: UserPublic?
    let buyerEmail: String?
    let buyerName: String?
    let cardNumber: String?
    let chargeId: String?
    let counterpartyName: String?
    let date: String?
    let discount: Double?
    let orderId: Int?
    let paymentIntentId: AnyCodable?
    let productPrice: Double?
    let receiver: UserPublic?
    let sellerId: Int?
    let sender: UserPublic?
    let shippingCharges: Double?
    let sourceType: String?
    let status: String?
    let subTotal: String?
    let taxAmount: String?
    let total: String?
    let type: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case id, buyer, date, discount, receiver, sender, status, total, type
        case accountNumber = "account_number"
        case buyerEmail = "buyer_email"
        case buyerName = "buyer_name"
        case cardNumber = "card_number"
        case chargeId = "charge_id"
        case counterpartyName = "counterparty_name"
        case orderId = "order_id"
        case paymentIntentId = "payment_intent_id"
        case productPrice = "product_price"
        case sellerId = "seller_id"
        case shippingCharges = "shipping_charges"
        case sourceType = "source_type"
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case userId = "user_id"
    }
}

// MARK: - Stripe SetupIntent helper (iOS-side; wraps Stripe SDK response)

struct StripeSetupIntent: Codable, Hashable {
    let clientSecret: String?
    let customerId: String?
    let ephemeralKey: String?

    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case customerId = "customer_id"
        case ephemeralKey = "ephemeral_key"
    }
}

// MARK: - Promo code (POST promo/verify-code)

typealias VerifyPromoCodeResponse = APIResponse<PromoCodeData>

struct PromoCodeData: Codable, Hashable {
    let id: Int?
    let code: String?
    let type: String?
    let value: Double?
    let description: String?
    let discountAmount: String?

    enum CodingKeys: String, CodingKey {
        case id, code, type, value, description
        case discountAmount = "discount_amount"
    }
}

struct VerifyPromoCodeRequest: Encodable {
    let code: String
    let sellerId: Int?

    enum CodingKeys: String, CodingKey {
        case code
        case sellerId = "seller_id"
    }
}

// MARK: - Fund transfer (POST api/stripe/fund-transfer)

typealias FundTransferResponse = APIResponse<FundTransferData>

struct FundTransferData: Codable, Hashable {
    let status: Bool?
    let message: String?
    let transferredAmount: Double?

    enum CodingKeys: String, CodingKey {
        case status, message
        case transferredAmount = "transferred_amount"
    }
}

struct FundTransferRequest: Encodable {
    let amount: String

    enum CodingKeys: String, CodingKey {
        case amount
    }
}
