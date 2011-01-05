# $Id: Version.pm 267050 2010-03-23 17:36:49Z nvigier $
package Youri::Submit::Check::Version;

=head1 NAME

Youri::Submit::Check::Version - Check if older version already exist in cooker (used in freeze period)

=head1 DESCRIPTION

This check plugin rejects new version of packages if they are not mentioned as authorized 
in the configuration file or in a non frozen section.

=cut

use warnings;
use strict;
use Carp;
use URPM;
use base qw/Youri::Submit::Check/;

sub _init {
    my $self   = shift;
    my %options = (
        @_
    );

    foreach my $target (keys %options) { 
	$self->{$target} = $options{$target}
    }
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $opt = $self->{$target};
    return if $opt->{mode} eq 'normal';
    my $section = $repository->_get_section($package, $target, $define);
    my $name = $package->get_canonical_name;
    return if $name =~ /$opt->{authorized_packages}/;
    my $arch = $repository->get_arch($package, $target, $define);
    return if $arch =~ /$opt->{authorized_arches}/;
    if ($opt->{mode} eq 'version_freeze') {
	return if $section =~ /$opt->{authorized_sections}/;
	my $user = $define->{user};
	return if $user =~ /^($opt->{authorized_users})$/;
	my ($package_version) = $package =~ /-([^-]+)-[^-]+\.src$/;
	$define->{arch} = 'src';
	my @revisions = $repository->get_revisions($package, $target, $define, undef,
	    sub {
		my ($version) = $_[0] =~ /-([^-]+)-[^-]+\.src$/;
		URPM::ranges_overlap("== $version", "< $package_version")
	    }
	);
	$define->{arch} = '';
	if (@revisions) {
	    return "FREEZE, package @revisions of different versions exist in $target\n";
	}
    }
    # FIXME: The following code is not working and must be reviewed.
    elsif ($opt->{mode} eq 'freeze') {
	my $user = $define->{user};
	return if (defined($opt->{authorized_users}) && $user =~ /^($opt->{authorized_users})$/);
	# XXX: So freeze mode really only check for this exceptions?
	if ($section !~ /$opt->{authorized_sections}/) {
	    return "FREEZE: repository $target section $section is frozen, you can still submit your packages in testing\nTo do so use your.devel --define section=<section> $target <package 1> <package 2> ... <package n>";
	}
    } else {
	# FIXME: Calls to get_source_package seems invalid nowadays.
	# This results on $source having a null content.
	my $source = $package->get_source_package;
	my ($package_version) = $source =~ /-([^-]+)-[^-]+\.src\.rpm$/;
	$define->{arch} = 'src';
	# FIXME: get_revisions now expects the filter as the 5th element, and not the 4th.
	my @revisions = $repository->get_revisions($package, $target, $define,
	    sub {
		# FIXME: Calls to get_source_package seems invalid nowadays.
		# This results on $source_package having a null content.
		my $source_package = $_[0]->get_source_package;
		my ($version) = $source_package =~ /-([^-]+)-[^-]+\.src\.rpm$/;
		print STDERR "Found version $version\n";
		URPM::ranges_overlap("== $version", "< $package_version")
	    }
	);
	$define->{arch} = '';
	if (@revisions) {
	    return "FREEZE, package @revisions of different versions exist in $target\n";
	}
    }
    return
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, YOURI project
Copyright (C) 2006, Mandriva

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;

