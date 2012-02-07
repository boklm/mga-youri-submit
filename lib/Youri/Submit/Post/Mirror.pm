# $Id: Gendistrib.pm 115367 2007-01-30 09:47:04Z pixel $
package Youri::Submit::Post::Mirror;

=head1 NAME

Youri::Submit::Post::Mirror - synchronizes repository to mirror

=head1 DESCRIPTION

Calls genhdlist2

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Post/;

sub _init {
    my $self   = shift;
    my %options = (
	destination => '',
        @_
    );

    foreach my $var ('destination') {
	$self->{"_$var"} = $options{$var};
    }
}

sub run {
    my ($self, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $root = $repository->get_install_root();

    croak "Missing destination" unless $self->{'_destination'};


    if (system("/usr/bin/rsync -alH --delete --delete-delay --delay-updates $root/$target/ $self->{_destination}/$target/")) {
	$self->{_error} = "Rsync command failed ($!)";
    }

    return;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010, Mageia

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;

