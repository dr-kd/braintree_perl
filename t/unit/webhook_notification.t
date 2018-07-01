# vim: sw=4 ts=4 ft=perl

use 5.010_001;
use strictures 1;

use Test::More;

use lib qw(lib t/lib);

use WebService::Braintree;
use WebService::Braintree::TestHelper;
use WebService::Braintree::MerchantAccount;
use WebService::Braintree::ErrorCodes::MerchantAccount;

subtest 'verify' => sub {
    my $verification_string = WebService::Braintree::WebhookNotification->verify('20f9f8ed05f77439fe955c977e4c8a53');
    is $verification_string, 'integration_public_key|d9b899556c966b3f06945ec21311865d35df3ce4';
};

subtest 'verify throws InvalidChallenge error if the challenge is not hexidecimal', sub {
    should_throw('InvalidChallenge', sub {
        WebService::Braintree::WebhookNotification->verify('bad challenge');
    }, 'challenge contains non-hex characters');
};

subtest 'sample_notification creates a parsable signature and payload', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
        'my_id',
    );
    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue;
    isnt $webhook_notification->timestamp, undef;
    is $webhook_notification->subscription->id, 'my_id';
};

subtest 'sample_notification throws InvalidSignature error if the signature is modified', sub {
    should_throw('InvalidSignature', sub {
        my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
            WebService::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
            'my_id',
        );
        my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature . 'bad', $payload);
    }, 'signature is invalid');
};

subtest 'sample_notification throws InvalidSignature error the public key is modified', sub {
    should_throw('InvalidSignature', sub {
        my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
            WebService::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
            'my_id',
        );
        my $webhook_notification = WebService::Braintree::WebhookNotification->parse('bad' . $signature, $payload);
    }, 'signature is invalid');
};

subtest 'sample_notification throws InvalidSignature error if the signature is invalid', sub {
    should_throw('InvalidSignature', sub {
        my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
            WebService::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
            'my_id',
        );
        my $webhook_notification = WebService::Braintree::WebhookNotification->parse('bad', $payload);
    }, 'signature is invalid');
};

subtest 'sample_notification creates a sample notification for an approved merchant account via webhook', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
        'my_id',
    );
    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::SubMerchantAccountApproved;
    is $webhook_notification->merchant_account->id, 'my_id';
    is $webhook_notification->merchant_account->status, WebService::Braintree::MerchantAccount::Status::Active;
    is $webhook_notification->merchant_account->master_merchant_account->id, 'master_ma_for_my_id';
    is $webhook_notification->merchant_account->master_merchant_account->status, WebService::Braintree::MerchantAccount::Status::Active;
};

subtest 'sample_notification builds a sample notification for a merchant account declined webhook', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined;
    is $webhook_notification->merchant_account->id, 'my_id';
    is $webhook_notification->merchant_account->status, WebService::Braintree::MerchantAccount::Status::Suspended;
    is $webhook_notification->merchant_account->master_merchant_account->id, 'master_ma_for_my_id';
    is $webhook_notification->merchant_account->master_merchant_account->status, WebService::Braintree::MerchantAccount::Status::Suspended;
    is $webhook_notification->message, 'Credit score is too low';
    is $webhook_notification->errors->for('merchant_account')->on('base')->[0]->code, WebService::Braintree::ErrorCodes::MerchantAccount::DeclinedOFAC;
};

subtest 'sample_notification builds a sample notification for disbursed transaction', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::TransactionDisbursed,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::TransactionDisbursed;
    is $webhook_notification->transaction->id, 'my_id';
    is $webhook_notification->transaction->amount, 100;
    isnt $webhook_notification->transaction->disbursement_details->disbursement_date, undef;
};

subtest 'sample_notification builds a sample notification for dispute opened', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::DisputeOpened,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::DisputeOpened;
    is $webhook_notification->dispute->status, WebService::Braintree::Dispute::Status::Open;
    is $webhook_notification->dispute->id, 'my_id';
};

subtest 'sample_notification builds a sample notification for dispute lost', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::DisputeLost,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::DisputeLost;
    is $webhook_notification->dispute->status, WebService::Braintree::Dispute::Status::Lost;
    is $webhook_notification->dispute->id, 'my_id';
};

subtest 'sample_notification builds a sample notification for dispute won', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::DisputeWon,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::DisputeWon;
    is $webhook_notification->dispute->status, WebService::Braintree::Dispute::Status::Won;
    is $webhook_notification->dispute->id, 'my_id';
};

subtest 'sample_notification builds a sample notification for disbursement exception', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::DisbursementException,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::DisbursementException;
    is $webhook_notification->disbursement->id, 'my_id';
    is $webhook_notification->disbursement->exception_message, 'bank_rejected';
    is $webhook_notification->disbursement->disbursement_date, '2014-02-10T00:00:00Z';
    is $webhook_notification->disbursement->follow_up_action, 'update_funding_information';
    is $webhook_notification->disbursement->merchant_account->id, 'merchant_account_token';
};

subtest 'sample_notification builds a sample notification for disbursement', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::Disbursement,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::Disbursement;
    is $webhook_notification->disbursement->id, 'my_id';
    is $webhook_notification->disbursement->exception_message, undef;
    is $webhook_notification->disbursement->disbursement_date, '2014-02-10T00:00:00Z';
    is $webhook_notification->disbursement->follow_up_action, undef;
    is $webhook_notification->disbursement->merchant_account->id, 'merchant_account_token';
};

subtest 'sample_notification builds a sample notification for partner merchant connected', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::PartnerMerchantConnected,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::PartnerMerchantConnected;
    is $webhook_notification->partner_merchant->partner_merchant_id, 'abc123';
    is $webhook_notification->partner_merchant->merchant_public_id, 'public_id';
    is $webhook_notification->partner_merchant->public_key, 'public_key';
    is $webhook_notification->partner_merchant->private_key, 'private_key';
    is $webhook_notification->partner_merchant->client_side_encryption_key, 'cse_key';
};

subtest 'sample_notification builds a sample notification for partner merchant disconnected', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::PartnerMerchantDisconnected,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::PartnerMerchantDisconnected;
    is $webhook_notification->partner_merchant->partner_merchant_id, 'abc123';
};

subtest 'sample_notification builds a sample notification for partner merchant declined', sub {
    my ($signature, $payload) = WebService::Braintree::WebhookTesting->sample_notification(
        WebService::Braintree::WebhookNotification::Kind::PartnerMerchantDeclined,
        'my_id',
    );

    my $webhook_notification = WebService::Braintree::WebhookNotification->parse($signature, $payload);

    is $webhook_notification->kind, WebService::Braintree::WebhookNotification::Kind::PartnerMerchantDeclined;
    is $webhook_notification->partner_merchant->partner_merchant_id, 'abc123';
};

done_testing();
