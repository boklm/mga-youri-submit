# $Id$
package Youri::Submit::Action::UpdateMaintDb;

=head1 NAME

Youri::Submit::Action::UpdateMaintDb - Mageia maintainers database updater

=head1 DESCRIPTION

This action plugin HTTP POSTs to package maintainers database to notify
of the action. See <http://maintdb.mageia.org/>.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

sub _init {
    my $self   = shift;
    my %options = (
	maintdb_binpath => '/usr/local/sbin/maintdb',
	maintdb_user => 'maintdb',
        @_
    );

    $self->{_maintdb_binpath} = $options{maintdb_binpath};
    $self->{_maintdb_user} = $options{maintdb_user};

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
        my $pkg_commiter = $define->{user};

	system('sudo', '-u', $self->{_maintdb_user}, $self->{_maintdb_binpath}, 'root', 'new', $pkg_name, $pkg_commiter);
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Mandriva
Copyright (C) 2011, Mageia.Org

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
