package Plack::Middleware::Evercookie::Png;

use strict;
use warnings;

use base 'Plack::Middleware::Evercookie::Base';

use HTTP::Date;
use GD;

sub run {
    my $self = shift;

    my $cookie = $self->req->cookies->{evercookie_png};

    if (!$cookie) {
        return [
            304,
            [   'Content-Type'   => 'image/png',
                'Content-Length' => 0,
                'Date'           => time2str(time)
            ],
            ['']
        ];
    }

    my @data = split '', $cookie;

    my $x = 200;
    my $y = 1;

    my $image = GD::Image->new($x, $y);

    $x = 0;
    $y = 0;

    for (my $i = 0; $i < @data; $i += 3) {
        my $color = $image->colorAllocate(
            ord($data[$i]),
            ord($data[$i + 1]),
            ord($data[$i + 2])
        );
        $image->setPixel($x++, $y, $color);
    }

    $image = $image->png;

    return [
        200,
        [   'Content-Type'   => 'image/png',
            'Content-Length' => length($image),
            'Date'           => time2str(time),
            'Last-Modified'  => 'Wed, 30 Jun 2010 21:36:48 GMT',
            'Expires'        => 'Tue, 31 Dec 2030 23:30:45 GMT',
            'Cache-Control'  => 'private, max-age=630720000'
        ],
        [$image]
    ];
}

1;
