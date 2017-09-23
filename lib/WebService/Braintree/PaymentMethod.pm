package WebService::Braintree::PaymentMethod;

use 5.010_001;
use strictures 1;

=head1 NAME

WebService::Braintree::PaymentMethod

=head1 PURPOSE

This class creates and finds payment methods.

=cut

use Moose;
extends 'WebService::Braintree::ResultObject';

=head1 CLASS METHODS

=head2 create()

This takes a hashref of parameters and returns the payment method created.

=cut

sub create {
    my ($class, $params) = @_;
    $class->gateway->payment_method->create($params);
}

=head2 update()

This takes a token and a hashref of parameters. It will update the
corresponding payment method (if found) and returns the updated payment method.

=cut

sub update {
    my ($class, $token, $params) = @_;
    $class->gateway->payment_method->update($token, $params);
}

=head2 delete()

This takes a token and deletes the corresponding payment method (if found).

=cut

sub delete {
    my ($class, $token) = @_;
    $class->gateway->payment_method->delete($token);
}

=head2 find()

This takes a token and returns the payment method (if it exists).

=cut

sub find {
    my ($class, $token) = @_;
    $class->gateway->payment_method->find($token);
}

sub gateway {
    return WebService::Braintree->configuration->gateway;
}

=head1 OBJECT METHODS

In addition to the methods provided by the keys returned from Braintree, this
class provides the following methods:

=head2 token()

=cut

has token => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 TODO

=over 4

=item Need to document the keys and values that are returned

=item Need to document the required and optional input parameters

=item Need to document the possible errors/exceptions

=back

=cut
