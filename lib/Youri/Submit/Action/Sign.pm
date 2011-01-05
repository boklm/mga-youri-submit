# $Id: Sign.pm 1700 2006-10-16 12:57:42Z warly $
package Youri::Submit::Action::Sign;

=head1 NAME

Youri::Submit::Action::Sign - GPG signature

=head1 DESCRIPTION

This action plugin ensures GPG signature of packages.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        name       => '',
        path       => $ENV{HOME} . '/.gnupg',
        passphrase => '',
        @_
    );

    croak "undefined name" unless $options{name};
    croak "undefined path" unless $options{path};
    croak "invalid path $options{path}" unless -d $options{path};

    $self->{_name}       = $options{name};
    $self->{_path}       = $options{path};
    $self->{_passphrase} = $options{passphrase};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    $package->sign(
        $self->{_name},
        $self->{_path},
        $self->{_passphrase}
    ) unless $self->{_test};
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
