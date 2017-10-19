package WebService::Braintree::ErrorCodes::Transaction;

use 5.010_001;
use strictures 1;

use constant AmountCannotBeNegative                            => "81501";
use constant AmountFormatIsInvalid                             => "81503";
use constant AmountIsInvalid                                   => "81503";
use constant AmountIsRequired                                  => "81502";
use constant AmountIsTooLarge                                  => "81528";
use constant AmountMustBeGreaterThanZero                       => "81531";
use constant BillingAddressConflict                            => "91530";
use constant CannotBeVoided                                    => "91504";
use constant CannotCancelRelease                               => "91562";
use constant CannotCloneCredit                                 => "91543";
use constant CannotCloneTransactionWithVaultCreditCard         => "91540";
use constant CannotCloneUnsuccessfulTransaction                => "91542";
use constant CannotCloneVoiceAuthorizations                    => "91541";
use constant CannotHoldInEscrow                                => "91560";
use constant CannotPartiallyRefundEscrowedTransaction          => "91563";
use constant CannotRefundCredit                                => "91505";
use constant CannotRefundSettlingTransaction                   => "91574";
use constant CannotRefundUnlessSettled                         => "91506";
use constant CannotRefundWithPendingMerchantAccount            => "91559";
use constant CannotRefundWithSuspendedMerchantAccount          => "91538";
use constant CannotReleaseFromEscrow                           => "91561";
use constant CannotSubmitForSettlement                         => "91507";
use constant CannotUpdateTransactionDetailsNotSubmittedForSettlement => '915129';
use constant CannotSimulateSettlement                          => "91575";
use constant ChannelIsTooLong                                  => "91550";
use constant CreditCardIsRequired                              => "91508";
use constant CustomFieldIsInvalid                              => "91526";
use constant CustomFieldIsTooLong                              => "81527";
use constant CustomerDefaultPaymentMethodCardTypeIsNotAccepted => "81509";
use constant CustomerDoesNotHaveCreditCard                     => "91511";
use constant CustomerIdIsInvalid                               => "91510";
use constant HasAlreadyBeenRefunded                            => "91512";
use constant MerchantAccountDoesNotSupportMOTO                 => "91558";
use constant MerchantAccountDoesNotSupportRefunds              => "91547";
use constant MerchantAccountIdIsInvalid                        => "91513";
use constant MerchantAccountIsSuspended                        => "91514";
use constant OrderIdIsTooLong                                  => "91501";
use constant PaymentInstrumentNotSupportedByMerchantAccount    => "91577";
use constant PaymentMethodConflict                             => "91515";
use constant PaymentMethodConflictWithVenmoSDK                 => "91549";
use constant PaymentMethodDoesNotBelongToCustomer              => "91516";
use constant PaymentMethodDoesNotBelongToSubscription          => "91527";
use constant PaymentMethodNonceCardTypeIsNotAccepted           => "91567";
use constant PaymentMethodNonceConsumed                        => "91564";
use constant PaymentMethodNonceLocked                          => "91566";
use constant PaymentMethodNonceUnknown                         => "91565";
use constant PaymentMethodTokenCardTypeIsNotAccepted           => "91517";
use constant PaymentMethodTokenIsInvalid                       => "91518";
use constant PayPalNotEnabled                                  => "91576";
use constant ProcessorAuthorizationCodeCannotBeSet             => "91519";
use constant ProcessorAuthorizationCodeIsInvalid               => "81520";
use constant ProcessorDoesNotSupportCredits                    => "91546";
use constant ProcessorDoesNotSupportVoiceAuthorizations        => "91545";
use constant PurchaseOrderNumberIsInvalid                      => "91548";
use constant PurchaseOrderNumberIsTooLong                      => "91537";
use constant RefundAmountIsTooLarge                            => "91521";
use constant ServiceFeeAmountCannotBeNegative                  => "91554";
use constant ServiceFeeAmountFormatIsInvalid                   => "91555";
use constant ServiceFeeAmountIsTooLarge                        => "91556";
use constant ServiceFeeAmountNotAllowedOnMasterMerchantAccount => "91557";
use constant ServiceFeeIsNotAllowedOnCredits                   => "91552";
use constant SettlementAmountIsLessThanServiceFeeAmount        => "91551";
use constant SettlementAmountIsTooLarge                        => "91522";
use constant SubMerchantAccountRequiresServiceFeeAmount        => "91553";
use constant SubscriptionDoesNotBelongToCustomer               => "91529";
use constant SubscriptionIdIsInvalid                           => "91528";
use constant SubscriptionStatusMustBePastDue                   => "91531";
use constant TaxAmountCannotBeNegative                         => "81534";
use constant TaxAmountFormatIsInvalid                          => "81535";
use constant TaxAmountIsTooLarge                               => "81536";
use constant ThreeDSecureAuthenticationFailed                  => "81571";
use constant ThreeDSecureTokenIsInvalid                        => "91568";
use constant ThreeDSecureTransactionDataDoesntMatchVerify      => "91570";
use constant TypeIsInvalid                                     => "91523";
use constant TypeIsRequired                                    => "91524";
use constant UnsupportedVoiceAuthorization                     => "91539";

1;
__END__
