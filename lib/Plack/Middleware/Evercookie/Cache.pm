package Plack::Middleware::Evercookie::Cache;

use strict;
use warnings;

use base 'Plack::Middleware::Evercookie::Base';

use HTTP::Date;

sub run {
    my $self = shift;

    my $cookie = $self->req->cookies->{evercookie_cache};

    if (!$cookie) {
        return [
            304,
            [   'Content-Type'   => 'text/html',
                'Content-Length' => 0,
                'Date'           => time2str(time)
            ],
            ['']
        ];
    }

    return [
        200,
        [   'Content-Type'   => 'text/html',
            'Content-Length' => length($cookie),
            'Date'           => time2str(time),
            'Last-Modified'  => 'Wed, 30 Jun 2010 21:36:48 GMT',
            'Expires'        => 'Tue, 31 Dec 2030 23:30:45 GMT',
            'Cache-Control'  => 'private, max-age=630720000'
        ],
        [$cookie]
    ];
}

1;
