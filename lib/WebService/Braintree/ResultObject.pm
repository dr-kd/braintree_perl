package WebService::Braintree::ResultObject;

use 5.010_001;
use strictures 1;

use Moose;
use Hash::Inflator;

use WebService::Braintree::Util qw(is_arrayref is_hashref);

sub set_attributes_from_hash {
    my ($self, $target, $attributes) = @_;
    while (my($attribute, $value) = each(%$attributes)) {
        __PACKAGE__->meta->add_attribute($attribute, is => 'rw');
        $target->$attribute($self->set_attr_value($value));
    }
}

sub set_attr_value {
    my ($self, $value) = @_;

    if (is_hashref($value)) {
        return Hash::Inflator->new($value);
    } elsif (is_arrayref($value)) {
        my $new_array = [];
        foreach (@$value) {
            push(@$new_array, $self->set_attr_value($_));
        }
        return $new_array;
    } else {
        return $value;
    }
}

sub build_sub_object {
    my $self = shift;
    my ($attributes, %options) = @_;
    my ($method, $class, $key) = @options{qw/method class key/};

    if (is_hashref($attributes->{$key})) {
        $self->$method( "WebService::Braintree::${class}"->new($attributes->{$key}) );
    }
    delete($attributes->{$key});
}

sub setup_sub_objects {
    my($self, $target, $params, $sub_objects) = @_;
    while (my($attribute, $class) = each(%$sub_objects)) {
        __PACKAGE__->meta->add_attribute($attribute, is => 'rw');
        if (is_arrayref($params->{$attribute})) {
            my $new_array = [];
            foreach my $element (@{$params->{$attribute}}) {
                push(@$new_array, $class->new($element)) if is_hashref($element);
            }
            $target->$attribute($new_array);
        } else {
            push(@{$target->$attribute}, $class->new($params->{$attribute})) if is_hashref($params->{$attribute});
        }
        delete($params->{$attribute});
    }
}

sub credit_card_details { shift->credit_card; }
sub customer_details { shift->customer; }
sub billing_details { shift->billing; }
sub shipping_details { shift->shipping; }
sub subscription_details { shift->subscription; }

1;
__END__
