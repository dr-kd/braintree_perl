# vim: sw=4 ts=4 ft=perl

package WebService::Braintree::WebhookTesting;

use 5.010_001;
use strictures 1;

use Moo;

with 'WebService::Braintree::Role::Interface';

sub sample_notification {
    my ($class, $kind, $id) = @_;

    return $class->gateway->webhook_testing->sample_notification($kind, $id);
}

__PACKAGE__->meta->make_immutable;

1;
__END__
