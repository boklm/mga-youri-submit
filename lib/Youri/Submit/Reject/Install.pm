# $Id: Install.pm 4747 2007-01-30 10:02:41Z pixel $
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
    $self->{_verbose} = $options{verbose};
}

sub run {
    my ($self, $package, $errors, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $file = $package->get_file();
    my $rpm = $package->get_file_name();
    my $dest = $repository->get_reject_path($package, $target, $define);

    # FIXME remove prefix this should be done by a function
    $rpm =~ s/^\d{14}\.\w+\.\w+\.\d+_//;
    print "installing file $file to $dest/$rpm\n" if $self->{_verbose};

    unless ($self->{_test}) {
        # create destination dir if needed
        system("install -d -m " . ($self->{_perms} + 111) . " $dest/")
            unless -d $dest;

        # install file to new location
        system("install -m $self->{_perms} $file $dest/$rpm");
    }
    $package->{_file} = "$dest/$rpm";
    print "deleting file $file\n" if $self->{_verbose};
    unlink $file unless $self->{_test};
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
