package Plack::Middleware::Evercookie::Dispatcher;

use strict;
use warnings;

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

    Plack::Util::load_class($class);

    return $class->new(env => $env)->run;
}

1;
