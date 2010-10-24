use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Plack::Middleware::NanoResponse',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/Plack/Middleware/NanoResponse.pm',
    build_requires      => {
        'Test::More'            => 0.88,
        'Plack::Test'           => 0,
        'HTTP::Request::Common' => 0,
    },
    requires => {
        'parent'            => 0,
        'Plack::Middleware' => 0,
    },
    add_to_cleanup      => [ 'Plack-Middleware-NanoResponse-*' ],
);

$builder->create_build_script();
