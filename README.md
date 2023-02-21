# NAME

WebService::Braintree - A Client Library for wrapping the Braintree Payment
Services Gateway API

## FORK

This is a fork of the original vendor-issued [Net::Braintree](https://metacpan.org/pod/Net%3A%3ABraintree).  While the
original is deprecated, it continues to work.  However, it contains a number
of code-style and maintainability problems.  This fork was produced to
address some of those problems and to provide a community driven basis for
going forward.

## DOCUMENTATION

The module is fully documented, but that documentation is reverse-engineered.
The public facing API is very similar to the Ruby libraries which are documented
at [https://developers.braintreepayments.com/ruby/sdk/server/overview](https://developers.braintreepayments.com/ruby/sdk/server/overview).

You can also look over the test suite for guidance of usage, especially the
`t/sandbox` tests.  Not all of these tests work (ones marked
`todo_skip`).  This is because they are an adaptation of code used against
Braintree's private integration server.

As of version 0.94, with appropriate manual intervention for your sandbox
account (documented in `t/sandbox/README`), more of the sandbox tests
run/pass for this module than for the original module [Net::Braintree](https://metacpan.org/pod/Net%3A%3ABraintree).

## OBJECT VS CLASS INTERFACE

As of January, 2018, Braintree released a large refactoring to how clients
interact with the Braintre API. They call the different class (old-style) vs.
object (new-style). Under the old style, configuration is global and all the
interactions with the API use the same configuration. Under the new style, each
call _could_ use a new configuration, if needed.

Both styles will be supported for the foreseeable future. Clients can still set
a global configuration and use the class interface, just like before.

In the documentation below, everything applies to both styles, except where
otherwise noted. If there is a difference between them, an exmaple of both will
be provided.

## GENERAL STYLE

In general, clients of this library will not instantiate any objects.  Every
call you make will be a class method.  Some methods will return objects.  In
those cases, those objects will be documented for you.

Unless otherwise noted, all attributes in these objects will be read-only and
will have been populated by the responses from Braintree.

### Object Style

If you use the object style, then you will instantiate and manage instances of
gateway objects. Each gateway object will have its own configuration.

## CONFIGURATION

You will need to set some configuration. Please see
["" in WebService::Braintree::Configuration](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AConfiguration) for details.

### Class Style

    use WebService::Braintree;

    my $conf = WebService::Braintree->configuration;
    $conf->environment( 'sandbox' );
    $conf->merchant_id( 'use_your_merchant_id' );
    $conf->public_key( 'use_your_public_key' );
    $conf->private_key( 'use_your_private_key' );

    my $result = WebService::Braintree::Transaction->sale(
        ...
    );

### Object Style

    use WebService::Braintree;

    my $gateway = WebService::Braintree::Gateway->new({
        environment => 'sandbox',
        merchant_id => 'use_your_merchant_id',
        public_key  => 'use_your_public_key',
        private_key => 'use_your_private_key',
    });

    my $result = $gateway->transaction->sale(
        ...
    );

### Client Tokens

In general, your server code (that uses this library) will be interacting with
a client-side SDK (such as for Mobile or Javascript).  That library will need a
client token in order to interact with Braintree.  This token will be all the
client-side needs, regardless of whether your server is pointing at the sandbox
or to production.

This token is created with ["generate" in WebService::Braintree::ClientToken](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AClientToken#generate).

## OBJECT INTERFACE

The object interface is described on each of the gateway classes. In general,
they are identical to the class interface described below, with the change that
you have invoked a method on a generic `$gateway` object instead of using
the class.

q.v. [WebService::Braintree::Gateway](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AGateway) for more information.

## CLASS INTERFACE

These are the classes that you will interface with.  Please see their
respective documentation for more detail on how to use them. These classes
only provide class methods. These methods all invoke some part of the
Braintree API.

### [WebService::Braintree::AddOn](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AAddOn)

List all plan add-ons.

### [WebService::Braintree::Address](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AAddress)

Create, update, delete, and find addresses.

### [WebService::Braintree::ApplePay](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AApplePay)

List, register, and unregister ApplePay domains.

### [WebService::Braintree::ClientToken](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AClientToken)

Generate client tokens.  These are used for client-side SDKs to take actions.

### [WebService::Braintree::CreditCard](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ACreditCard)

Create, update, delete, and find credit cards.

### [WebService::Braintree::CreditCardVerification](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ACreditCardVerification)

Find and list credit card verifications.

### [WebService::Braintree::Customer](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ACustomer)

Create, update, delete, and find customers.

### [WebService::Braintree::Discount](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ADiscount)

List all plan discounts.

### [WebService::Braintree::Dispute](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ADispute)

Accept, and find disputes.

### [WebService::Braintree::DocumentUpload](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ADocumentUpload)

Manage document uploads.

### [WebService::Braintree::EuropeBankAccount](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AEuropeBankAccount)

Find Europe Bank Accounts.

### [WebService::Braintree::IdealPayment](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AIdealPayment)

Find IdealPayment payment methods.

### [WebService::Braintree::Merchant](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AMerchant)

Provision merchants from "raw ApplePay".

### [WebService::Braintree::MerchantAccount](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AMerchantAccount)

Create, update, and find merchant accounts.

### [WebService::Braintree::PaymentMethod](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3APaymentMethod)

Create, update, delete, and find payment methods.

### [WebService::Braintree::PaymentMethodNonce](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3APaymentMethodNonce)

Create, update, delete, and find payment method nonces.

### [WebService::Braintree::PayPalAccount](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3APayPalAccount)

Find and update PayPal accounts.

### [WebService::Braintree::Plan](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3APlan)

List all subscription plans.

### [WebService::Braintree::SettlementBatchSummary](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ASettlementBatchSummary)

Generate settlement batch summaries.

### [WebService::Braintree::Subscription](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ASubscription)

Create, update, cancel, find, and handle charges for subscriptions.

### [WebService::Braintree::Transaction](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ATransaction)

Create, manage, and search for transactions.  This is the workhorse class and it
has many methods.

### [WebService::Braintree::TransactionLineItem](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ATransactionLineItem)

Find all the transaction line-items.

### [WebService::Braintree::TransparentRedirect](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3ATransparentRedirect)

Manage the transparent redirection of ????.

**NOTE**: This class needs significant help in documentation.

### [WebService::Braintree::UsBankAccount](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AUsBankAccount)

Find US Bank Accounts.

## SEARCHING

Several of the interfaces provide a `search()` method.  This method
is unique in that it takes a subroutine reference (subref) instead of a hashref
or other parameters.

### Example

    my $results = WebService::Braintree::Transaction->search(sub {
        my $search = shift;
        $search->amount->between(10, 20);
    });

### Additional Documentation

The various field types are documenated at [WebService::Braintree::AdvancedSearchNodes](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AAdvancedSearchNodes).

## RESPONSES

Responses from the interface methods will either be a
[Result](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AResult) or an
[ErrorResult](https://metacpan.org/pod/WebService%3A%3ABraintree%3A%3AErrorResult). You can distinguish between
them by calling `$result->is_success`.

### Success

If the request is successful, Braintee will reply back and you will receive
(in most cases) a ["WebService::Braintree::Result" in result](https://metacpan.org/pod/result#WebService::Braintree::Result) object. This object
will allow you to access the various components of the response.

In some cases, you will receive something different. Those cases are documented
in the method itself.

### Failure

If there is an issue with the request, Braintree will reply back and you will
receive a ["WebService::Braintree::ErrorResult" in ErrorResult](https://metacpan.org/pod/ErrorResult#WebService::Braintree::ErrorResult) object. It will
contain a ["WebService::Braintree::ValidationErrorCollection" in collection](https://metacpan.org/pod/collection#WebService::Braintree::ValidationErrorCollection) of
["WebService::Braintree::Error" in errors](https://metacpan.org/pod/errors#WebService::Braintree::Error) explaining each issue with the request.

## ISSUES

The bugtracker is at [https://github.com/singingfish/braintree\_perl/issues](https://github.com/singingfish/braintree_perl/issues).

Patches welcome!

## CONTRIBUTING

Contributions are welcome.  The process:

- Submissions

    Please fork this repository on Github, create a branch, then submit a pull
    request from that branch to the master of this repository.  All other
    submissions will be summarily rejected.

- Developer Environment

    We use Docker to encapsulate the developer environment.  There is a Bash script
    in the root called `run_tests` that provides an entrypoint to how this
    project uses Docker.  The sequence is:

    - run\_tests build

        This will build the Docker developer environment for each Perl version listed
        in `PERL_VERSIONS`

    - run\_tests unit \[ command \]

        This will run the unit tests for each Perl version listed in
        `PERL_VERSIONS`. You can provide a `prove` command to limit which
        test(s) you run.

    - run\_tests integration \[ command \]

        This will run the sandbox tests for each Perl version listed in
        `PERL_VERSIONS`. You can provide a `prove` command to limit which
        test(s) you run.

    - run\_tests cover

        This will run the all the tests for each Perl version listed in
        `PERL_VERSIONS` and calculate the coverage.

    You can optionally select a Perl version or versions (5.10 through 5.24) to
    run the command against by setting the `PERL_VERSIONS` environment
    variable.  Use a space to separate multiple versions.

    This Bash script has been tested to work in Linux, OSX, and GitBash on Windows.

    - Signup

        Navigate to [https://www.braintreepayments.com/sandbox](https://www.braintreepayments.com/sandbox).  Enter your first name,
        last name, Company name of "WebService::Braintree", your country, and your email
        address.

    - Activate your account

        You will receive an email to the address you provided which will contain a link.
        Click on it and you'll sent to a page where you will be asked for a password.

    - Create a sandbox\_config.json

        On the dashboard page of your new sandbox account, three are three values you
        will need to put into a `sandbox_config.json`.  The format of the file must
        be:

            {
              "merchant_id": "<< value 1 >>",
              "public_key": "<< value 2 >>",
              "private_key": "<< value 3 >>"
            }

        replacing what's in the double-quotes with the appropriate values from your
        Braintree sandbox's dashboard.

    - Link your Paypal Sandbox Account

        You'll need to follow the instructions at [https://developers.braintreepayments.com/guides/paypal/testing-go-live/ruby#linked-paypal-testing](https://developers.braintreepayments.com/guides/paypal/testing-go-live/ruby#linked-paypal-testing).  This is
        required for some of the integration tests to pass.

        Within Setting > Processing, select "Link your sandbox" within the PayPal
        section.

        Once at the Paypal Developer Dashboard:

        - My Apps & Credentials
        - Rest Apps
        - Create new App
        - Give it a name
        - Copy the information requested back to Braintree

    - Run the tests

        You can now run the integration tests with `run_tests integration`.  These
        tests will take between 5 and 20 minutes.

## TODO/WISHLIST/ROADMAP

- Many of the integration tests are still skipped.
- There aren't enough unit tests.
- The documentation is still sparse, especially for the PURPOSE sections.

## ACKNOWLEDGEMENTS

Thanks to the staff at Braintree for endorsing this fork.

Thanks to ZipRecruiter for sponsoring improvements to the forked code.

Thanks to Rob Kinyon for refactoring significant portions of the codebase.

## LICENSE AND COPYRIGHT

Copyright 2017 Kieren Diment <zarquon@cpan.org>

Copyright 2011-2014 Braintree, a division of PayPal, Inc.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
