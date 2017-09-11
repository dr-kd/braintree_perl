package WebService::Braintree::PaymentMethodNonce;

use Moose;
extends 'WebService::Braintree::ResultObject';

sub create {
  my ($class, $token) = @_;
  $class->gateway->payment_method_nonce->create($token);
}

sub find {
  my ($class, $token) = @_;
  $class->gateway->payment_method_nonce->find($token);
}

sub gateway {
  return WebService::Braintree->configuration->gateway;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
