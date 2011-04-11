#!/usr/bin/env perl

use strict;
use warnings;

use Plack::Builder;

use lib '../lib';

my $body = <<'EOF';
<!doctype html>
    <head>
        <script type="text/javascript" src="/jquery.js" language="javascript"></script>
        <script type="text/javascript" src="/jquery.cookie.js" language="javascript"></script>
        <script type="text/javascript" src="/jquery.dump.js" language="javascript"></script>
        <script type="text/javascript" src="/evercookie/swfstore.js" language="javascript"></script>
        <script type="text/javascript" src="/evercookie/evercookie.js" language="javascript"></script>
    </head>
    <body>
        <script>
            function genUID() {
                var uid = '';

                var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
                var string_length = 8;
                for (var i = 0; i < string_length; i++) {
                    var rnum = Math.floor(Math.random() * chars.length);
                    uid += chars.substring(rnum, rnum + 1);
                }

                return uid;
            }

            $(document).ready(function() {
                var ec = new Evercookie();

                ec.ready(function() {
                    ec.get('uid', function(value) {
                        if (!value) {
                            value = genUID();
                        }

                        ec.set('uid', value);

                        $('#uid').html('<span>' + value + '</span>');
                    });
                });
            });
        </script>

        <h2>Your unique id is: <span id="uid"></span></h2>
        <small>Try refreshing your browser, cleaning cache, cookies etc</small>
        <br />
    </body>
</html>
EOF

my $app = sub {
    my $env = shift;
    if ($env->{PATH_INFO} eq '/') {
        return [
            200,
            [   'Content-Type'   => 'text/html',
                'Content-Length' => length($body)
            ],
            [$body]
        ];
    }
    else {
        return [
            404, ['Content-Type' => 'text/html', 'Content-Length' => 9],
            ['Not Found']
        ];
    }
};

builder {
    enable "Static", root => 'htdocs', path => qr{\.(?:css|js|swf|xap)$};

    enable "Evercookie";

    $app;
};
