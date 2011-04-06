use strict;
use warnings;

use Test::More tests => 5;

use_ok('Plack::Middleware::Evercookie::Etag');

use HTTP::Date;

my $env = {};
my $middleware = Plack::Middleware::Evercookie::Etag->new(env => $env);
is_deeply(
    $middleware->run(),
    [   200,
        [   'Content-Type'   => 'text/plain',
            'Content-Length' => 0
        ],
        ['']
    ]
);

$env = {HTTP_IF_NONE_MATCH => '123'};
$middleware = Plack::Middleware::Evercookie::Etag->new(env => $env);
is_deeply(
    $middleware->run(),
    [   304,
        [   'Content-Type'   => 'text/plain',
            'Content-Length' => 0,
            'Date'           => time2str(time),
            'ETag'           => 123,
            'Cache-Control'  => 'private'
        ],
        ['']
    ]
);

$env = {HTTP_COOKIE => '123'};
$middleware = Plack::Middleware::Evercookie::Etag->new(env => $env);
is_deeply(
    $middleware->run(),
    [   200,
        [   'Content-Type'   => 'text/plain',
            'Content-Length' => 0
        ],
        ['']
    ]
);

$env = {HTTP_COOKIE => 'evercookie_etag=123'};
$middleware = Plack::Middleware::Evercookie::Etag->new(env => $env);
is_deeply(
    $middleware->run(),
    [   200,
        [   'Content-Type'   => 'text/plain',
            'Content-Length' => 3,
            'ETag'           => '123',
            'Date'           => time2str(time),
            'Cache-Control'  => 'private'
        ],
        ['123']
    ]
);
