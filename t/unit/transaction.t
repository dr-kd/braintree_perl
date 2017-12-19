# vim: sw=4 ts=4 ft=perl

use 5.010_001;
use strictures 1;

use Test::More;

use lib qw(lib t/lib);

use WebService::Braintree;
use WebService::Braintree::TestHelper;

subtest 'params tests' => sub {
    should_throw('ArgumentError', sub { WebService::Braintree::Transaction->sale({'foo' => 'Bar'}); });
};

subtest 'validates clone_transaction params'  => sub {
    should_throw('ArgumentError', sub {
        WebService::Braintree::Transaction->clone_transaction('foo', { invalid_param => 'something'});
    });
};

subtest 'raises error if find is passed a blank string' => sub {
    should_throw('NotFoundError', sub { WebService::Braintree::Transaction->find('') });
    should_throw('NotFoundError', sub { WebService::Braintree::Transaction->find('  ') });
};

subtest 'details' => sub {
    my $result = WebService::Braintree::Transaction->new({
        amount => amount(40, 60),
        credit_card => credit_card({
            expiration_date  => '05/12',
        }),
        customer => {first_name => 'Dan', last_name => 'Smith'},
        billing => { street_address => '123 45 6' },
        shipping => { street_address => '789 10 11' },
        options  => {
            store_in_vault  => 'true',
            add_billing_address_to_payment_method => 'true',
            store_shipping_address_in_vault => 'true',
        },
    });

    is $result->shipping_details->street_address, '789 10 11';
    is $result->billing_details->street_address, '123 45 6';
    is $result->credit_card_details->expiration_date, '05/12';
    is $result->customer_details->first_name, 'Dan';
};

done_testing();
