package Plack::Middleware::Evercookie;

use strict;
use warnings;

use base 'Plack::Middleware';

our $VERSION = '0.00901';

use Plack::Util::Accessor qw(base);

use Plack::Middleware::Evercookie::Dispatcher;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{dispatcher} ||= Plack::Middleware::Evercookie::Dispatcher->new;

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $base = $self->base || 'evercookie';
    $base = quotemeta $base;

    if ($env->{PATH_INFO} =~ m{^/$base/([a-z]+)$}) {
        my $res =  $self->{dispatcher}->dispatch($env, $1);
        use Data::Dumper;
        warn Dumper $res;
        return $res;
    }

    return $self->app->($env);
}

1;
