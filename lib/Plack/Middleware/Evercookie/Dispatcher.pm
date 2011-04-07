package Plack::Middleware::Evercookie::Dispatcher;

use strict;
use warnings;

use Try::Tiny;
use Plack::Util ();

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub dispatch {
    my $self = shift;
    my ($env, $action) = @_;

    $action = ucfirst $action;
    my $class = "Plack::Middleware::Evercookie::$action";

    my $res;
    try {
        Plack::Util::load_class($class);
        $res = $class->new(env => $env)->run;
    }
    catch {
        die $_ unless $_ =~ m/^Can't locate [^ ]+ in \@INC/;
    };

    return $res;
}

1;
