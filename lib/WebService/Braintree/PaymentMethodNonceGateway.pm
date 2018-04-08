# vim: sw=4 ts=4 ft=perl

package # hide from pause
    WebService::Braintree::PaymentMethodNonceGateway;

use 5.010_001;
use strictures 1;

use Moose;
with 'WebService::Braintree::Role::MakeRequest';

use WebService::Braintree::Util qw(validate_id);

use WebService::Braintree::_::PaymentMethodNonce;

sub create {
    my ($self, $token) = @_;
    if (!validate_id($token)) {
        confess "NotFoundError";
    }
    $self->_make_request("/payment_methods/${token}/nonces", 'post');
}

sub find {
    my ($self, $token) = @_;
    if (!validate_id($token)) {
        confess "NotFoundError";
    }

    $self->_make_request("/payment_method_nonces/" . $token, 'get');
}

__PACKAGE__->meta->make_immutable;

1;
__END__
