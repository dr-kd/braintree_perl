package WebService::Braintree::Role::MakeRequest;

use 5.010_001;
use strictures 1;

use Moose::Role;

sub _make_request {
    my($self, $path, $verb, $params) = @_;
    my $response = $self->gateway->http->$verb($path, $params);
    my $result = WebService::Braintree::Result->new(response => $response);
    return $result;
}

1;
__END__
