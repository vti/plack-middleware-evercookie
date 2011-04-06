package Plack::Middleware::Evercookie::Base;

use strict;
use warnings;

use Plack::Request;
use Scalar::Util qw(weaken);

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    weaken $self->{env};

    return $self;
}

sub env { shift->{env} }

sub req {
    my $self = shift;

    $self->{req} ||= Plack::Request->new($self->env);

    return $self->{req};
}

sub run {
    die 'Overwrite';
}

1;
