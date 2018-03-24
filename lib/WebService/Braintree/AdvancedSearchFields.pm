# vim: sw=4 ts=4 ft=perl

package # hide from pause
    WebService::Braintree::AdvancedSearchFields;

use 5.010_001;
use strictures 1;

use Carp;
use Moose;

use WebService::Braintree::Util qw(is_arrayref);

has "metaclass" => (is => 'rw');

sub field {
    my ($self, $name, $node) = @_;
    $self->metaclass->add_attribute($name, is => 'rw', default => $node);
}

sub is {
    my ($self, $name) = @_;
    $self->field($name, sub {
        return WebService::Braintree::IsNode->new(searcher => shift, name => $name);
    });
}

sub equality {
    my ($self, $name) = @_;
    $self->field($name, sub {
        return WebService::Braintree::EqualityNode->new(searcher => shift, name => $name);
    });
}

sub text {
    my ($self, $name) = @_;
    $self->field($name, sub {
        return WebService::Braintree::TextNode->new(searcher => shift, name => $name);
    });
}

sub key_value {
    my ($self, $name) = @_;
    $self->field($name, sub {
        return WebService::Braintree::KeyValueNode->new(searcher => shift, name => $name);
    });
}

sub range {
    my ($self, $name) = @_;
    $self->field($name, sub {
        return WebService::Braintree::RangeNode->new(searcher => shift, name => $name);
    });
}

sub multiple_values {
    my ($self, $name, @allowed_values) = @_;

    # Inflate all arrayrefs
    @allowed_values = map {
        is_arrayref($_) ? @$_ : $_
    } @allowed_values;

    my $node = sub {
        return WebService::Braintree::MultipleValuesNode->new(
            searcher => shift,
            name => $name,
            allowed_values => @allowed_values ? [@allowed_values] : undef,
        );
    };
    $self->field($name, $node);
}

sub partial_match {
    my ($self, $name) = @_;
    $self->field($name, sub {
        return WebService::Braintree::PartialMatchNode->new(searcher => shift, name => $name);
    });
}

__PACKAGE__->meta->make_immutable;

1;
__END__
