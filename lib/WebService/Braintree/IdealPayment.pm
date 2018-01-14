package WebService::Braintree::IdealPayment;

use 5.010_001;
use strictures 1;

=head1 NAME

WebService::Braintree::IdealPayment

=head1 PURPOSE

This class finds IdealPayment payment methods.

=cut

use Moose;
extends 'WebService::Braintree::PaymentMethod';

=head1 CLASS METHODS

=head2 find()

This takes a token and returns the IdealPayment (if it exists).

=cut

sub find {
    my ($class, $token) = @_;
    $class->gateway->ideal_payment->find($token);
}

=head2 sale()

This takes a token and an optional hashref of parameters and creates a sale
transaction on the provided token.

=cut

sub sale {
    my ($class, $ideal_payment_id, $params) = @_;
    WebService::Braintree::Transaction->sale({
        %{$params//{}},
        payment_method_nonce => $ideal_payment_id,
        options => { submit_for_settlement => 1 },
    });
}

sub gateway {
    WebService::Braintree->configuration->gateway;
}

sub BUILD {
    my ($self, $attrs) = @_;

    $self->set_attributes_from_hash($self, $attrs);
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NOTES

Most of the classes normally used in WebService::Braintree inherit from
L<WebService::Braintree::ResultObject/>. This class, however, inherits from
L<WebService::Braintree::PaymentMethod/>. The primary benefit of this is that
these objects have a C<< token() >> attribute.

=head1 TODO

=over 4

=item Need to document the keys and values that are returned

=item Need to document the required and optional input parameters

=item Need to document the possible errors/exceptions

=back

=cut
