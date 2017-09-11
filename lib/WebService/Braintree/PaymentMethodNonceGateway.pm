package WebService::Braintree::PaymentMethodNonceGateway;

use Moose;
with 'WebService::Braintree::Role::MakeRequest';

has 'gateway' => (is => 'ro');

sub create {
    my ($self, $token) = @_;
    if (!defined($token) || WebService::Braintree::Util::trim($token) eq "") {
        confess "NotFoundError";
    }
    my $response = $self->_make_request("/payment_methods/${token}/nonces", 'post');
    return $response;
}

sub find {
    my ($self, $token) = @_;
    if (!defined($token) || WebService::Braintree::Util::trim($token) eq "") {
        confess "NotFoundError";
    }

    my $response = $self->_make_request("/payment_method_nonces/" . $token, 'get');
    return $response;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
