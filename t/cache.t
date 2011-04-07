use strict;
use warnings;

use Test::More tests => 4;

use_ok('Plack::Middleware::Evercookie::Cache');

use HTTP::Date;

my $env = {};
my $middleware = Plack::Middleware::Evercookie::Cache->new(env => $env);
is_deeply(
    $middleware->run(),
    [   304,
        [   'Content-Type'   => 'text/html',
            'Content-Length' => 0,
            'Date'           => time2str(time),
        ],
        ['']
    ]
);

$env = {HTTP_COOKIE => 'foo=bar'};
$middleware = Plack::Middleware::Evercookie::Cache->new(env => $env);
is_deeply(
    $middleware->run(),
    [   304,
        [   'Content-Type'   => 'text/html',
            'Content-Length' => 0,
            'Date'           => time2str(time),
        ],
        ['']
    ]
);

$env = {HTTP_COOKIE => 'evercookie_cache=123'};
$middleware = Plack::Middleware::Evercookie::Cache->new(env => $env);
is_deeply $middleware->run(),
  [ 200,
    [   'Content-Type'   => 'text/html',
        'Content-Length' => 3,
        'Date'           => time2str(time),
        'Last-Modified'  => 'Wed, 30 Jun 2010 21:36:48 GMT',
        'Expires'        => 'Tue, 31 Dec 2030 23:30:45 GMT',
        'Cache-Control'  => 'private, max-age=630720000',
    ],
    ['123']
  ];
