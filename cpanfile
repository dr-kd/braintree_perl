requires 'Class::Load::XS';
requires 'DDP';
requires 'Data::GUID';
requires 'DateTime';
requires 'DateTime::Format::Atom';
requires 'DateTime::Format::RFC3339';
requires 'DateTime::Format::Strptime';
requires 'Digest';
requires 'Digest::HMAC_SHA1';
requires 'Digest::SHA';
requires 'Digest::SHA1';
requires 'Digest::SHA256';
requires 'HTTP::Request';
requires 'Hash::Inflator';
requires 'JSON';
requires 'LWP', '6.02';
requires 'LWP::Protocol::https';
requires 'MIME::Base64';
requires 'Module::Install::TestTarget';
requires 'Moo';
requires 'MooX::Aliases';
requires 'Mozilla::CA';
requires 'Scalar::Util';
requires 'Try::Tiny';
requires 'Type::Tiny';
requires 'URI';
requires 'URI::Query';
requires 'XML::LibXML';
requires 'XML::Simple';
requires 'local::lib';
requires 'perl', '5.010001';
requires 'strictures';

on build => sub {
    requires 'ExtUtils::MakeMaker';
};

on test => sub {
    requires 'Data::Printer';
    requires 'String::CamelCase';
    requires 'Test::Deep';
    requires 'Test::More', '0.98';
    requires 'Test::Pod';
    requires 'Test::Warn';
};
