# $Id$
package Youri::Submit::Action::Install;

=head1 NAME

Youri::Submit::Action::Install - Package installation

=head1 DESCRIPTION

This action plugin ensures installation of new package revisions.

=cut

use warnings;
use strict;
use Carp;
use File::Basename;
use base qw/Youri::Submit::Action/;

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
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $file = $package->as_file();
    my $rpm = basename($package->get_file_name());
    my $dest = $repository->get_install_dir($package, $target, $define);

    # FIXME remove prefix this should be done by a function
    $rpm =~ s/^\d{14}\.\w*\.\w+\.\d+_//;
    $rpm =~ s/^\@\d+://;
    print "installing file $file to $dest/$rpm\n" if $self->{_verbose};

    unless ($self->{_test}) {
        # create destination dir if needed
        if (! -d $dest) {
            my $status =
                system("install -d -m " . ($self->{_perms} + 111) . " $dest");
            croak "Unable to create directory $dest: $?" if $status;
        }

        # install file to new location
        my $status =
            system("install -m $self->{_perms} $file $dest/$rpm");
        croak "Unable to install file $file to $dest/$rpm: $?" if $status;

	my $arch = $package->get_arch();
	$repository->set_arch_changed($target, $arch);
	$repository->set_install_dir_changed($dest);
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
