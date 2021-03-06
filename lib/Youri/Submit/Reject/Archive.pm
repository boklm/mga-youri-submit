# $Id$
package Youri::Submit::Reject::Install;

=head1 NAME

Youri::Submit::Action::Archive - Old revisions archiving

=head1 DESCRIPTION

This action plugin ensures archiving of old package revisions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Reject/;

sub _init {
    my $self   = shift;
    my %options = (
        perms => 644,
        @_
    );

    $self->{_perms} = $options{perms};

    return $self;
}

sub run {
    my ($self, $package, $errors, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $file = $package->as_file();
    my $rpm = $package->get_file_name();
    my $dest = $repository->get_reject_dir($package, $target, $define);

    # FIXME remove prefix this should be done by a function
    $rpm =~ s/^\d{14}\.\w+\.\w+\.\d+_//;
    print "installing file $file to $dest/$rpm\n" ;#if $self->{_verbose};

    unless ($self->{_test}) {
        # create destination dir if needed
        system("install -d -m " . ($self->{_perms} + 111) . " $dest/")
            unless -d $dest;

        # install file to new location
        system("install -m $self->{_perms} $file $dest/$rpm");
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
