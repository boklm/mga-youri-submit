# $Id$
package Youri::Submit::Action::UpdateMdvDb;

=head1 NAME

Youri::Submit::Action::UpdateMdvDb - Mandriva maintainers database updater

=head1 DESCRIPTION

This action plugin calls an external script to update last commit info, as
well as add new packages, in the package maintainers database at
<http://maint.mandriva.com/>.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        @_
    );

    # path for mdvdb-updaterep script
    $self->{_mdvdb_updaterep} = $options{mdvdb_updaterep};

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    # only SRPMs matter
    return unless $package->is_source();

    unless ($self->{_test}) {
        my $pkg_name = $package->get_name();
        my $pkg_media = $repository->_get_main_section($package, $target, $define);
        $package->get_packager() =~ m/(\w[-_.\w]+\@[-_.\w]+)\W/;
        my $pkg_commiter = $1;

        if (system($self->{_mdvdb_updaterep}, "update", $pkg_name, $pkg_media, $pkg_commiter, "youri")) {
            print "ERROR: ".$self->{_mdvdb_updaterep}." failed for '$pkg_name', '$pkg_media', '$pkg_commiter'.\n";
        } else {
            print "Updated package maintainers DB for '$pkg_name', '$pkg_media', '$pkg_commiter'.\n" if $self->{_verbose};
        }
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Mandriva

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
