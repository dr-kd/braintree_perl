# vim: sw=4 ts=4 ft=perl

use 5.010_001;
use strictures 1;

use Test::More;

use lib qw(lib t/lib);

use WebService::Braintree::Nonce;
use WebService::Braintree::TestHelper qw(sandbox);
use WebService::Braintree;
use WebService::Braintree::ErrorCodes::Descriptor;

require 't/lib/WebService/Braintree/Nonce.pm';

WebService::Braintree::TestHelper->verify_sandbox
    || BAIL_OUT 'Sandbox is not prepared properly. Please read xt/README.';

my $customer = WebService::Braintree::Customer->create({
    first_name => "Fred",
    last_name => "Fredson",
});
my $card = WebService::Braintree::CreditCard->create({
    number => "5431111111111111",
    expiration_date => "05/12",
    customer_id => $customer->customer->id,
});

# TODO Add a BAIL_OUT if the above fail for any reason

subtest "create without trial" => sub {
    my $result = WebService::Braintree::Subscription->create({
        payment_method_token => $card->credit_card->token,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
    });
    ok $result->is_success;
    like $result->subscription->id, qr/^\w{6}$/;
    is $result->subscription->status, 'Active';
    is $result->subscription->plan_id, WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID;

    isnt $result->subscription->transactions->[0], undef;

    is $result->subscription->failure_count,  0;
    is $result->subscription->next_bill_amount,  "12.34";
    is $result->subscription->next_billing_period_amount,  "12.34";
    is $result->subscription->payment_method_token,  $card->credit_card->token;

    cmp_ok($result->subscription->created_at, ">=", DateTime->now - DateTime::Duration->new(minutes => 60));
    cmp_ok($result->subscription->updated_at, ">=", DateTime->now - DateTime::Duration->new(minutes => 60));

    my $transaction = $result->subscription->transactions->[0];

    is_deeply $transaction->subscription->billing_period_start_date, $result->subscription->billing_period_start_date;
    is_deeply $transaction->subscription->billing_period_end_date, $result->subscription->billing_period_end_date;
    is_deeply $transaction->subscription_details->billing_period_end_date, $result->subscription->billing_period_end_date;
    is $transaction->plan_id, WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID;

    is $result->subscription->current_billing_cycle, 1;

    is $result->subscription->trial_period, 0;
    is $result->subscription->trial_duration, undef;
    is $result->subscription->trial_duration_unit, undef;
};

subtest "create with descriptors" => sub {
    plan skip_all => "descriptors don't work";

    my $result = WebService::Braintree::Subscription->create({
        payment_method_token => $card->credit_card->token,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
        descriptor => {
            name => "abc*def",
            phone => "1234567890",
            url => "ebay.com",
        },
    });
    ok $result->is_success;
    my $transaction = $result->subscription->transactions->[0];
    is $transaction->descriptor->name, "abc*def";
    is $transaction->descriptor->phone, "1234567890";
    is $transaction->descriptor->url, "ebay.com";
};

subtest "create with descriptor validations" => sub {
    plan skip_all => "descriptors don't work";

    my $result = WebService::Braintree::Subscription->create({
        payment_method_token => $card->credit_card->token,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
        descriptor => {
            name => "abc",
            phone => "12345678",
            url => "12345678901234",
        },
    });
    not_ok $result->is_success;
    is($result->errors->for("subscription")->for("descriptor")->on("name")->[0]->code, WebService::Braintree::ErrorCodes::Descriptor::NameFormatIsInvalid);
    is($result->errors->for("subscription")->for("descriptor")->on("phone")->[0]->code, WebService::Braintree::ErrorCodes::Descriptor::PhoneFormatIsInvalid);
    is($result->errors->for("subscription")->for("descriptor")->on("url")->[0]->code, WebService::Braintree::ErrorCodes::Descriptor::UrlFormatIsInvalid);
};

subtest "create with trial, add-ons, discounts" => sub {
    my $result = WebService::Braintree::Subscription->create({
        payment_method_token => $card->credit_card->token,
        plan_id => "integration_plan_with_add_ons_and_discounts",
        discounts => {
            add => [{
                inherited_from_id => "discount_15"
            }],
        },
        add_ons => {
            add => [{
                inherited_from_id => "increase_30",
            }],
        },
        options => {
            do_not_inherit_add_ons_or_discounts => 'true',
        },
    });

    ok $result->is_success;

    is $result->subscription->add_ons->[0]->id, "increase_30";
    is $result->subscription->add_ons->[0]->amount, '30.00';
    is $result->subscription->add_ons->[0]->quantity, 1;
    is $result->subscription->add_ons->[0]->number_of_billing_cycles, undef;
    ok $result->subscription->add_ons->[0]->never_expires;
    is $result->subscription->add_ons->[0]->current_billing_cycle, 0;

    is $result->subscription->discounts->[0]->id, "discount_15";
    is $result->subscription->discounts->[0]->amount, '15.00';
    is $result->subscription->discounts->[0]->quantity, 1;
    is $result->subscription->discounts->[0]->number_of_billing_cycles, undef;
    ok $result->subscription->discounts->[0]->never_expires;
    is $result->subscription->discounts->[0]->current_billing_cycle, 0;
};

subtest "create with payment method nonce" => sub {
    my $nonce = WebService::Braintree::TestHelper::get_nonce_for_new_card("4111111111111111", $customer->customer->id);
    my $subscription_params = {
        payment_method_nonce => $nonce,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
    };
    my $result = WebService::Braintree::Subscription->create($subscription_params);

    ok $result->is_success;

    my $credit_card = WebService::Braintree::CreditCard->find($result->subscription->payment_method_token);
    is $credit_card->masked_number, "411111******1111";
};

subtest "create with a paypal account" => sub {
    my $nonce = WebService::Braintree::Nonce->paypal_future_payment;
    my $customer_result = WebService::Braintree::Customer->create({
        payment_method_nonce => $nonce
    });

    my $customer = $customer_result->customer;
    my $subscription_result = WebService::Braintree::Subscription->create({
        payment_method_token => $customer->paypal_accounts->[0]->token,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
    });

    ok $subscription_result->is_success;
    my $subscription = $subscription_result->subscription;
    ok($subscription->payment_method_token eq $customer->paypal_accounts->[0]->token);
};

subtest "retry charge" => sub {
    plan skip_all => "make_subscription_past_due receives a 404";

    my $subscription = WebService::Braintree::Subscription->create({
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
        payment_method_token => $card->credit_card->token,
    })->subscription;

    make_subscription_past_due($subscription->id);

    my $retry = WebService::Braintree::Subscription->retry_charge($subscription->id);

    ok $retry->is_success;
    is $retry->transaction->amount, $subscription->price;
};

subtest "if transaction fails, no subscription gets returned" => sub {
    my $result = WebService::Braintree::Subscription->create({
        payment_method_token => $card->credit_card->token,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
        price => "2000.00",
    });

    not_ok $result->is_success;
    is $result->message, "Do Not Honor";
};

subtest "With a specific subscription" => sub {
    my $create = WebService::Braintree::Subscription->create({
        payment_method_token => $card->credit_card->token,
        plan_id => WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID,
    });

    subtest "find" => sub {
        my $result = WebService::Braintree::Subscription->find($create->subscription->id);

        is $result->trial_period, 0;
        is $result->plan_id, WebService::Braintree::TestHelper->TRIALLESS_PLAN_ID;

        should_throw("NotFoundError", sub {
            WebService::Braintree::Subscription->find("asdlkfj");
        });
    };

    subtest "update" => sub {
        my $result = WebService::Braintree::Subscription->update($create->subscription->id, {price => "50.00"});

        ok $result->is_success;
        is $result->subscription->price, "50.00";

        should_throw("NotFoundError", sub {
            WebService::Braintree::Subscription->update("asdlkfj", {
                price => "50.00",
            });
        });
    };

    subtest "update payment method with payment method nonce" => sub {
        my $nonce = WebService::Braintree::TestHelper::get_nonce_for_new_card("4242424242424242", $customer->customer->id);
        my $subscription_params = {payment_method_nonce => $nonce};

        my $result = WebService::Braintree::Subscription->update($create->subscription->id, $subscription_params);

        ok $result->is_success;

        my $credit_card = WebService::Braintree::CreditCard->find($result->subscription->payment_method_token);
        is $credit_card->masked_number, "424242******4242";
    };

    subtest "cancel" => sub {
        my $result = WebService::Braintree::Subscription->cancel($create->subscription->id);
        ok $result->is_success;

        $result = WebService::Braintree::Subscription->cancel($create->subscription->id);
        not_ok $result->is_success;
        is $result->message, "Subscription has already been canceled."
    };
};

done_testing();
