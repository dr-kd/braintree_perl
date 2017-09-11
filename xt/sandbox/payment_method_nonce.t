# vim: sw=4 ts=4 ft=perl

use Test::More;

use lib qw(lib t/lib);

use WebService::Braintree;
use WebService::Braintree::PaymentMethodNonce;
use WebService::Braintree::TestHelper qw(sandbox);

subtest "creates a payment method nonce from a vaulted credit card" => sub {
    my $customer = WebService::Braintree::Customer->create->customer;
    isnt($customer->id, undef, '.. customer->id is defined');
    my $test_cc_number = '4111111111111111';

    my $nonce = WebService::Braintree::TestHelper::nonce_for_new_credit_card({
        number => $test_cc_number,
        expirationMonth => "12",
        expirationYear => "2020",
        options => {
            validate => "false",
        },
    });

    isnt($nonce, undef, '.. nonce is defined');

    my $result = WebService::Braintree::PaymentMethod->create({
        payment_method_nonce => $nonce,
        customer_id => $customer->id,
        billing_address => {
            street_address => "123 Abc Way",
        },
    });

    ok($result->is_success, '.. result is successful');

    isnt($result->payment_method, undef, '.. we have a payment method');
    my $token = $result->payment_method->token;

    my $found_credit_card = WebService::Braintree::CreditCard->find($token);
    isnt($found_credit_card, undef, '.. we can find the credit card from the token');

    {
        my $create_result = WebService::Braintree::PaymentMethodNonce->create($found_credit_card->token);
        ok($create_result->is_success, '.. creating a nonce from a token is_success');
        ok($create_result->{response}->{payment_method_nonce}->{nonce}, '.. we get a nonce');
        ok($create_result->payment_method_nonce->nonce, '.. we get a nonce object');
        is($create_result->{response}->{payment_method_nonce}->{nonce}, $create_result->payment_method_nonce->nonce, '.. nonce accessor created successfully');
        ok($create_result->payment_method_nonce->details, '.. we have details');
        is($create_result->payment_method_nonce->details->last_two, substr($test_cc_number, -2), '.. details match the credit card');
    }
};

subtest "thrown serror with invalid tokens" => sub {
    should_throw('NotFoundError', sub {
        my $create_result = WebService::Braintree::PaymentMethodNonce->create('not_a_token');
    }, '.. correctly raises an exception for a non existent token');
};

subtest "finds (fake) valid nonce, returns it" => sub {
    my $token = 'fake-valid-nonce';

    my $result = WebService::Braintree::PaymentMethodNonce->find($token);

    my $nonce = $result->payment_method_nonce;

    ok($result->is_success, '.. result is successful');
    is($nonce->nonce, $token, '.. returns the correct nonce');
    is($nonce->type, 'CreditCard', '.. returns the correct type');
    is($nonce->details->last_two, '81', '.. details->last_two set correctly');
    is($nonce->details->card_type, 'Visa', '.. details->card_type set correctly');
};

subtest "returns null 3ds_info if there isn't any" => sub {
    my $nonce = WebService::Braintree::TestHelper::nonce_for_new_credit_card({
        number => '4111111111111111',
        expirationMonth => "11",
        expirationYear => "2099",
    });

    my $result = WebService::Braintree::PaymentMethodNonce->find($nonce);
    my $nonce = $result->payment_method_nonce;
    ok($result->is_success, '.. result is successful');
    is($nonce->three_d_secure_info, undef, '.. three_d_secure_info is null');
};

subtest "correctly raises and exception for a non existent token" => sub {
    should_throw('NotFoundError', sub {
        my $create_result = WebService::Braintree::PaymentMethodNonce->create('not_a_nonce');
    }, '.. correctly raises an exception for a non existent nonce');
};

done_testing();
