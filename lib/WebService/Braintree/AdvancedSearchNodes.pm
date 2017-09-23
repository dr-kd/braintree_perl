{
    package WebService::Braintree::AdvancedSearchNodes;

    use 5.010_001;
    use strictures 1;

    use Moose;
}

{
    package WebService::Braintree::SearchNode;

    use 5.010_001;
    use strictures 1;

    use Moose;

    has 'searcher' => (is => 'rw');
    has 'name' => (is => 'rw');

    has 'criteria' => (is => 'rw', default => sub {shift->default_criteria()});

    sub default_criteria {
        return {};
    }

    sub active {
        my $self = shift;
        return %{$self->criteria};
    }

    sub add_node {
        my ($self, $operator, $operand) = @_;
        $self->criteria->{$operator} = $operand;
        return $self->searcher;
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::IsNode;

    use 5.010_001;
    use strictures 1;

    use Moose;
    extends ("WebService::Braintree::SearchNode");

    sub is {
        my ($self, $operand) = @_;
        return $self->add_node("is", $operand);
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::EqualityNode;

    use 5.010_001;
    use strictures 1;

    use Moose;
    extends ("WebService::Braintree::IsNode");

    sub is_not {
        my ($self, $operand) = @_;
        return $self->add_node("is_not", $operand);
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::KeyValueNode;

    use 5.010_001;
    use strictures 1;

    use Moose;
    extends ("WebService::Braintree::SearchNode");

    sub default_criteria {
        return "";
    }

    sub active {
        my $self = shift;
        return $self->criteria;
    }

    sub is {
        my ($self, $operand) = @_;
        $self->criteria($operand);
        return $self->searcher;
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::PartialMatchNode;

    use 5.010_001;
    use strictures 1;

    use Moose;
    extends ("WebService::Braintree::EqualityNode");

    sub starts_with {
        my ($self, $operand) = @_;
        return $self->add_node("starts_with", $operand);
    }

    sub ends_with {
        my ($self, $operand) = @_;
        return $self->add_node("ends_with", $operand);
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::TextNode;

    use 5.010_001;
    use strictures 1;

    use Moose;
    extends ("WebService::Braintree::PartialMatchNode");

    sub contains {
        my ($self, $operand) = @_;
        return $self->add_node("contains", $operand);
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::RangeNode;

    use 5.010_001;
    use strictures 1;

    use Moose;
    extends ("WebService::Braintree::EqualityNode");

    use overload ( '>=' => 'min', '<=' => 'max');

    sub min {
        my ($self, $operand) = @_;
        return $self->add_node("min", $operand);
    }

    sub max {
        my ($self, $operand) = @_;
        return $self->add_node("max", $operand);
    }

    sub between {
        my ($self, $min, $max) = @_;
        $self->max($max);
        $self->min($min);
    }
    __PACKAGE__->meta->make_immutable;
    1;
}

{
    package WebService::Braintree::MultipleValuesNode;

    use 5.010_001;
    use strictures 1;

    use Carp;
    use Moose;
    use WebService::Braintree::Util qw(difference_arrays is_arrayref);
    extends ("WebService::Braintree::SearchNode");

    has 'allowed_values' => (is => 'rw');

    sub default_criteria {
        return [];
    }

    sub active {
        my $self = shift;
        return @{$self->criteria};
    }

    sub is {
        shift->in(@_);
    }

    sub _args_to_array {
        my $self = shift;
        my @args;
        if (is_arrayref($_[0])) {
            @args = @{$_[0]};
        } else {
            @args = @_;
        }
        return @args;
    }

    sub in {
        my $self = shift;
        my @values = $self->_args_to_array(@_);

        my $bad_values = difference_arrays(\@values, $self->allowed_values);

        if (@$bad_values && $self->allowed_values) {
            croak "Invalid Argument(s) for " . $self->name . ": " . join(", ", @$bad_values);
        }

        @{$self->criteria} = @values;
        return $self->searcher;
    }
    __PACKAGE__->meta->make_immutable;
    1;
}
