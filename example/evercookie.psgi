#!/usr/bin/env perl

use strict;
use warnings;

use Plack::Builder;

use lib '../lib';

my $body = <<'EOF';
<!doctype html>
    <head>
        <script type="text/javascript" src="/jquery.js" language="javascript"></script>
        <script type="text/javascript" src="/swfobject.js" language="javascript"></script>
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
                $(window).load(function() {
                    ec = new evercookie({base: '/evercookie/'});

                    ec.get('uid', function(value) {
                        var uid;
                        if (typeof value == 'undefined') {
                            uid = genUID();
                        }
                        else {
                            uid = value;
                        }
                        ec.set('uid', uid);

                        $('#uid').html(uid);
                    }, 1);
                });
            });
        </script>

        <h2>Your unique id is: <span id="uid"></span></h2>
        <small>Try refreshing your browser, cleaning cache, cookies etc</small>
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
