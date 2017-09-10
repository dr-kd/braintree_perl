# vim: sw=4 ts=4 ft=perl

use Test::More;

use lib qw(lib t/lib);

use WebService::Braintree;
use WebService::Braintree::Xml;
use WebService::Braintree::TestHelper;

subtest "should survive some deep parsing" => sub {
    my $xml = q{
<parent>
<nulls type="array"/>
<singles type="array">
<single><name>Foo</name></single>
</singles>
<doubles type="array">
<double><name>First</name></double>
<double><name>Second</name></double>
</doubles>
<deep type="array">
<item>
<singles type="array">
<single><name>Foo</name></single>
</singles>
<doubles type="array">
<double><name>First</name></double>
<double><name>Second</name></double>
</doubles>
</item>
</deep>
</parent>

};

    my $hash = xml_to_hash($xml);
    is $hash->{parent}->{nulls}->[0], undef;
    is $hash->{parent}->{singles}->[0]->{name}, "Foo";
    is $hash->{parent}->{doubles}->[1]->{name}, "Second";

    is $hash->{parent}->{deep}->[0]->{doubles}->[1]->{name}, "Second";
};

done_testing();
