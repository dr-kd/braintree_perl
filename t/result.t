# vim: sw=4 ts=4 ft=perl

use Test::More;

use lib qw(lib t/lib);

use WebService::Braintree::TestHelper;
use WebService::Braintree::Result;

subtest "multiple errors" => sub {
    my $response = {
        'api_error_response' => {
            "message" => "Customer ID is invalid.\nCredit card number is invalid."
        }
    };

    my $result = WebService::Braintree::Result->new(response => $response);
    not_ok $result->is_success;
    is ($result->message, "Customer ID is invalid.\nCredit card number is invalid.");
};

subtest "allow access to relevant objects on response" => sub {
    my $response = {
        transaction => {
            amount => "44.00",
            type => "sale"
        }
    };

    my $result = WebService::Braintree::Result->new(response => $response);
    is($result->transaction->amount, "44.00");
    is($result->customer, undef);
};

subtest "allow access to relevant objects on error response" => sub {
    my $response = {
        'api_error_response' => {
            subscription => {
                id => "42",
                random_subscription_info => "foo"
            }
        }
    };

    my $result = WebService::Braintree::Result->new(response => $response);
    is($result->subscription->random_subscription_info, "foo");
    is($result->transaction, undef);
};

done_testing();
