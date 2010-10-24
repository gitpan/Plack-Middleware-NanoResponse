use strict;
use Plack::Builder;
use HTTP::Request::Common;

use Test::More 0.88;
use Plack::Test;

my $res = sub { [ 201, ['Content-Type' => 'text/plain'], ['default'] ] };

{
    my $app = builder {
        enable 'NanoResponse',
            path   => '/chk',
            status => 200,
            head   => { 'Content-Type' => 'text/html' },
            body   => 'OK';
        $res;
    };
    my $cli = sub {
            my $cb = shift;
            my $res = $cb->(GET '/'); # no match, default response(is $res)
            is $res->code, 201;
            is $res->content_type, 'text/plain';
            is $res->content, 'default';
    };
    test_psgi $app, $cli;

    my $cli2 = sub {
            my $cb = shift;
            my $res = $cb->(GET '/chk'); # match, response is $app
            is $res->code, 200;
            is $res->content_type, 'text/html';
            is $res->content_length, 2;
            is $res->content, 'OK';
    };
    test_psgi $app, $cli2;
}

{
    # path is undef, default response
    my $app = builder {
        enable 'NanoResponse';
        $res;
    };
    my $cli = sub {
            my $cb = shift;
            my $res = $cb->(GET '/');
            is $res->code, 200;
            is $res->content_type, 'text/plain';
            is $res->content, '';
    };
    test_psgi $app, $cli;
}

{
    # path only
    my $app = builder {
        enable 'NanoResponse',
            path => '/chk';
        $res;
    };
    my $cli = sub {
            my $cb = shift;
            my $res = $cb->(GET '/chk');
            is $res->code, 200;
            is $res->content_type, 'text/plain';
            is $res->content, '';
    };
    test_psgi $app, $cli;

    # path is code ref
    my $app2 = builder {
        enable 'NanoResponse',
            path => sub { $_[0] eq '/chk' };
        $res;
    };
    test_psgi $app2, $cli;
}

{
    # 500 Internal Server Error
    my $app = builder {
        enable 'NanoResponse',
            path   => '/chk',
            status => 500,
            head   => { 'Content-Type' => 'text/plain' },
            body   => 'Internal Server Error';
        $res;
    };
    my $cli = sub {
            my $cb = shift;
            my $res = $cb->(GET '/chk');
            is $res->code, 500;
            is $res->content_type, 'text/plain';
            is $res->content, 'Internal Server Error';
    };
    test_psgi $app, $cli;
}

done_testing;
