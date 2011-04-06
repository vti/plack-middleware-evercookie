package Plack::Middleware::Evercookie::Etag;

use strict;
use warnings;

use base 'Plack::Middleware::Evercookie::Base';

use HTTP::Date;

sub run {
    my $self = shift;

    my $cookie = $self->req->cookies->{evercookie_etag};

    my $headers = [];
    my $body    = '';

    if ($cookie) {
        return [
            200,
            [   'Content-Type'   => 'text/plain',
                'Content-Length' => length($cookie),
                'ETag'           => $cookie,
                'Date'           => time2str(time),
                'Cache-Control'  => 'private'
            ],
            [$cookie]
        ];
    }
    else {
        my $etag = $self->req->headers->header('If-None-Match');

        if ($etag) {
            return [
                304,
                [   'Content-Type' => 'text/plain',

                    'Content-Length' => 0,
                    'Date'           => time2str(time),
                    'ETag'           => $etag,
                    'Cache-Control'  => 'private'
                ],
                ['']
            ];
        }

        return [
            200,
            [   'Content-Type'   => 'text/plain',
                'Content-Length' => 0,
            ],
            ['']
        ];
    }
}

1;
