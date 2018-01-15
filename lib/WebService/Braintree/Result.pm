package WebService::Braintree::Result;

use 5.010_001;
use strictures 1;

use Moose;

use WebService::Braintree::Util qw(is_hashref);
use WebService::Braintree::ValidationErrorCollection;

# Load these here because they aren't an interface, but a result class.
use WebService::Braintree::Nonce;

my $response_objects = {
    add_on => 'WebService::Braintree::AddOn',
    address => 'WebService::Braintree::Address',
    apple_pay => 'WebService::Braintree::ApplePay',
    apple_pay_card => 'WebService::Braintree::ApplePayCard',
    credit_card => 'WebService::Braintree::CreditCard',
    #credit_card_verification => 'WebService::Braintree::CreditCardVerification',
    customer => 'WebService::Braintree::Customer',
    dispute => 'WebService::Braintree::Dispute',
    discount => 'WebService::Braintree::Discount',
    document_upload => 'WebService::Braintree::DocumentUpload',
    europe_bank_account => 'WebService::Braintree::EuropeBankAccount',
    evidence => 'WebService::Braintree::Dispute::Evidence',
    ideal_payment => 'WebService::Braintree::IdealPayment',
    merchant => 'WebService::Braintree::Merchant',
    merchant_account => 'WebService::Braintree::MerchantAccount',
    payment_method => {
        credit_card => 'WebService::Braintree::CreditCard',
        paypal_account => 'WebService::Braintree::PayPalAccount',
    },
    payment_method_nonce => 'WebService::Braintree::Nonce',
    paypal_account => 'WebService::Braintree::PayPalAccount',
    settlement_batch_summary => 'WebService::Braintree::SettlementBatchSummary',
    subscription => 'WebService::Braintree::Subscription',
    transaction => 'WebService::Braintree::Transaction',
    us_bank_account => 'WebService::Braintree::UsBankAccount',
};

has response => ( is => 'ro' );

sub _get_response {
    my $self = shift;
    return $self->response->{api_error_response} || $self->response;
}

my $meta = __PACKAGE__->meta;

sub patch_in_response_accessors {
    my $field_rules = shift;
    while (my($key, $rule) = each(%$field_rules)) {
        if (is_hashref($rule)) {
            $meta->add_method($key => sub {
                my $self = shift;
                my $response = $self->_get_response();
                while (my($subkey, $subrule) = each(%$rule)) {
                    my $field_value = $self->$subkey;
                    if ($field_value) {
                        keys %$rule;
                        return $field_value;
                    }
                }

                return;
            });

            patch_in_response_accessors($rule);
        } else {
            $meta->add_method($key => sub {
                my $self = shift;
                my $response = $self->_get_response();
                if (!$response->{$key}) {
                    return;
                }

                return $rule->new($response->{$key});
            });
        }
    }
}

patch_in_response_accessors($response_objects);

sub api_error_response {
    my $self = shift;
    return $self->response->{api_error_response};
}

sub message {
    my $self = shift;
    return $self->api_error_response->{message} if $self->api_error_response;
    return '';
}

sub errors {
    my $self = shift;
    return WebService::Braintree::ValidationErrorCollection->new($self->api_error_response->{errors});
}

sub credit_card_verification {
    my $self = shift;
    return WebService::Braintree::CreditCardVerification->new($self->api_error_response->{verification});
}

sub is_success { # 1 }
    my $self = shift;

    return if $self->response->{api_error_response};

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
