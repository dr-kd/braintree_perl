package WebService::Braintree::CreditCardGateway;

use 5.010_001;
use strictures 1;

use Moose;
with 'WebService::Braintree::Role::MakeRequest';
with 'WebService::Braintree::Role::CollectionBuilder';

use Carp qw(confess);
use WebService::Braintree::Validations qw(verify_params credit_card_signature);
use WebService::Braintree::Util qw(validate_id);
use WebService::Braintree::Result;
use Try::Tiny;

has 'gateway' => (is => 'ro');

sub create {
    my ($self, $params) = @_;
    confess "ArgumentError" unless verify_params($params, credit_card_signature);
    $self->_make_request("/payment_methods/", "post", {credit_card => $params});
}

sub delete {
    my ($self, $token) = @_;
    $self->_make_request("/payment_methods/credit_card/$token", "delete", undef);
}

sub update {
    my ($self, $token, $params) = @_;
    confess "ArgumentError" unless verify_params($params, credit_card_signature);
    $self->_make_request("/payment_methods/credit_card/$token", "put", {credit_card => $params});
}

sub find {
    my ($self, $token) = @_;
    confess "NotFoundError" unless validate_id($token);
    $self->_make_request("/payment_methods/credit_card/$token", "get", undef)->credit_card;
}

sub from_nonce {
    my ($self, $nonce) = @_;
    confess "NotFoundError" unless validate_id($nonce);

    try {
        return $self->_make_request("/payment_methods/from_nonce/$nonce", "get", undef)->credit_card;
    } catch {
        confess "Payment method with nonce $nonce locked, consumed or not found";
    }
}

sub expired {
    my ($self) = @_;

    return $self->resource_collection({
        ids_url => "/payment_methods/all/expired_ids",
        obj_url => "/payment_methods/all/expired",
        inflate => [qw/payment_methods credit_card CreditCard/],
    });
}

sub expiring_between {
    my ($self, $start, $end) = @_;

    $start = $start->strftime('%m%Y');
    $end   = $end->strftime('%m%Y');
    my $params = "start=${start}&end=${end}";

    return $self->resource_collection({
        ids_url => "/payment_methods/all/expiring_ids?${params}",
        obj_url => "/payment_methods/all/expiring?${params}",
        inflate => [qw/payment_methods credit_card CreditCard/],
    });
}

__PACKAGE__->meta->make_immutable;

1;
__END__
