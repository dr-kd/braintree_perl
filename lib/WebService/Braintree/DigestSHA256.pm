package WebService::Braintree::DigestSHA256;

use 5.010_001;
use strictures 1;

use Digest;
use Digest::SHA;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(new);
our @EXPORT_OK = qw();

sub new {
    return Digest->new("SHA-256");
}

1;
__END__
