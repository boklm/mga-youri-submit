# $Id: Markrelease.pm 4743 2007-01-30 09:58:30Z pixel $
package Youri::Submit::Action::Markrelease;

=head1 NAME

Youri::Submit::Action::Markrelease - calls markrelease

=head1 DESCRIPTION

This action plugin calls markrelease

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        perms => 644,
        @_
    );

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    $package->is_source or return 1;
    my $file = $package->get_file();
    my $srpm_name = $package->get_canonical_name;

    if ($repository->package_in_svn($srpm_name)) {
	my $svn = $repository->get_svn_url();
	my ($rev) = $file =~ /.*\/.*?\@(\d+):/;
	print "Run repsys markrelease -f $file -r $rev $svn/$srpm_name\n";
	# FIXME repsys ask for a username and password
	# FIXME we should use the key in /var/home/mandrake so that /home/mandrake does not
	# need to be mounted
	system('mgarepo', 'markrelease', '-f', $file, '-r', $rev, "$svn/$srpm_name");
    }
    1
}
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
