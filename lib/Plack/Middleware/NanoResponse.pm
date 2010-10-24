package Plack::Middleware::NanoResponse;
use strict;
use warnings;

use parent qw/Plack::Middleware/;
use Plack::Util::Accessor qw/path status head body/;

our $VERSION = '0.01';

sub call {
    my ($self, $env) = @_;

    my $res = $self->_handle($env);
    return $res if $res;
    return $self->app->($env);
}

sub _handle {
    my ( $self, $env ) = @_;

    my $target_path = $self->path || '';
    for my $req_path ($env->{PATH_INFO}) {
        my $match = ref $target_path eq 'CODE'
                        ? $target_path->($req_path) : $req_path =~ $target_path;
        return unless $match;
    }

    my $res_status  = int($self->status || 200);
    my $res_body    = $self->body || '';
    my $len         = length $res_body;
    my $res_headers = { 'Content-Type' => 'text/plain', 'Content-Length' => $len };
    if ($self->head) {
        for my $key (keys %{$self->head}) {
            $res_headers->{$key} = $self->head->{$key};
        }
    }

    return [ $res_status, [%{$res_headers}], [$res_body] ];
}


1;

__END__

=head1 NAME

Plack::Middleware::NanoResponse - response a canned response


=head1 SYNOPSIS

    # in your_app.psgi
    
    use Plack::Builder;
    
    my $app = sub { 
        # ... 
    };
    builder {
        enable 'NanoResponse',
            path => '/chk',
            head => { 'Content-Type' => 'text/html' },
            body => 'OK';
        $app;
    };


=head1 DESCRIPTION

Plack::Middleware::NanoResponse is a Plack middleware component that responses a canned response.


=head1 Repository

<MODULE NAME> is hosted on github
at http://github.com/bayashi/Plack-Middleware-NanoResponse


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

L<Plack::Middleware>, L<Plack::Builder>, L<Plack>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
