use strict;
use warnings;

use Test::More tests => 5;

use_ok('Plack::Middleware::Evercookie::Png');

use HTTP::Date;

my $env = {};
my $middleware = Plack::Middleware::Evercookie::Png->new(env => $env);
is_deeply(
    $middleware->run(),
    [   304,
        [   'Content-Type'   => 'image/png',
            'Content-Length' => 0,
            'Date'           => time2str(time),
        ],
        ['']
    ]
);

$env = {HTTP_COOKIE => 'foo=bar'};
$middleware = Plack::Middleware::Evercookie::Png->new(env => $env);
is_deeply(
    $middleware->run(),
    [   304,
        [   'Content-Type'   => 'image/png',
            'Content-Length' => 0,
            'Date'           => time2str(time),
        ],
        ['']
    ]
);

$env = {HTTP_COOKIE => 'evercookie_png=123'};
$middleware = Plack::Middleware::Evercookie::Png->new(env => $env);
my $res = $middleware->run();
is $res->[0] => '200';
is_deeply $res->[1],
  [ 'Content-Type'   => 'image/png',
    'Content-Length' => 83,
    'Date'           => time2str(time),
    'Last-Modified'  => 'Wed, 30 Jun 2010 21:36:48 GMT',
    'Expires'        => 'Tue, 31 Dec 2030 23:30:45 GMT',
    'Cache-Control'  => 'private, max-age=630720000',
  ];
