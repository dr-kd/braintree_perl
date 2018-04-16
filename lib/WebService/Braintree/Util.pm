# vim: sw=4 ts=4 ft=perl

package # hide from pause
    WebService::Braintree::Util;

use 5.010_001;
use strictures 1;

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
    hash_to_query_string
    to_instance_array
    is_not_empty validate_id
    is_arrayref is_hashref
);

use URI::Query;

# USED by ::TransparentRedirectGateway->build_tr_data and
#   ::TestHelper->simulate_form_post_for_tr
sub hash_to_query_string {
    my $query = URI::Query->new(__flatten(shift));
    return $query->stringify();
}

# USED only by __hash_to_query_string()
sub __flatten {
    my($hash, $namespace) = @_;
    my %flat_hash = ();
    while (my ($key, $value) = each(%$hash)) {
        if (is_hashref($value)) {
            my $sub_entries = __flatten($value, __add_namespace($key, $namespace));
            %flat_hash = (%flat_hash, %$sub_entries);
        } else {
            $flat_hash{__add_namespace($key, $namespace)} = $value;
        }
    }
    return \%flat_hash;
}

# USED only by __flatten()
sub __add_namespace {
    my ($key, $namespace) = @_;
    return $key unless $namespace;
    return "${namespace}[${key}]";
}

sub to_instance_array {
    my ($attrs, $class) = @_;
    my @result = ();
    if (! is_arrayref($attrs)) {
        push(@result, $class->new($attrs));
    } else {
        for (@$attrs) {
            push(@result, $class->new($_));
        }
    }
    return \@result;
}

sub is_not_empty {
    my $content = shift;
    return if ! defined $content or length($content) == 0;
    return 1;
}

sub validate_id {
    my $id = shift;

    return if ! is_not_empty($id);
    return if $id =~ /\s/;

    return 1;
}

sub is_hashref {
    ref(shift) eq 'HASH';
}

sub is_arrayref {
    ref(shift) eq 'ARRAY';
}

1;
__END__
