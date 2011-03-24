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
        maintdb_url => '',
        maintdb_key => '',
        @_
    );

    $self->{_maintdb_url}     = $options{maintdb_url};
    $self->{_maintdb_key}     = $options{maintdb_key};

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

        $ua = LWP::UserAgent->new;
        $ua->agent('Youri/0.1 ' . $ua->agent);

        my $req = POST $self->{_maintdb_url},
                      [
                        key     => $self->{_maintdb_key},
                        from    => "youri",
                        package => $pkg_name,
                        media   => $pkg_media,
                        uid     => $pkg_commiter
                      ];

        my $res = $ua->request($req);

        if ($res->is_success) {
            print "Updated package maintainers DB for '$pkg_name', '$pkg_media', '$pkg_commiter'.\n" if $self->{_verbose};
        } else {
            print "ERROR: POST failed to ".$self->{_maintdb_url}." for '$pkg_name', '$pkg_media', '$pkg_commiter'.\n";
        }
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Mandriva
Copyright (C) 2011, Mageia.Org

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
