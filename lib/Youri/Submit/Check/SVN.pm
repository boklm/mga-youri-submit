# $Id: SVN.pm 4747 2007-01-30 10:02:41Z pixel $
package Youri::Submit::Check::SVN;

=head1 NAME

Youri::Submit::Check::Tag - Incorrect tag values check

=head1 DESCRIPTION

This check plugin rejects packages with incorrect tag values, based on regular
expressions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

sub _init {
    my $self   = shift;
    my %options = (
	svn => '',
	@_
    );
    $self->{_svn} = $options{svn};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $section = $repository->_get_section($package, $target, $define);
    if ($section =~ /\/(testing|backport)$/) {
	# FIXME, right now ignore packages in SVN for testing and backports
	# we need to find a clean way to handle them
	return
    }

    $package->is_source or return;
    my $file = $package->get_file_name;
    my $srpm_name = $package->get_canonical_name;
    if ($repository->package_in_svn($srpm_name)) {
	if ($file !~ /(^|\/|$define->{prefix}_)@\d+:\Q$srpm_name/)  {
	    return "package $srpm_name is in the SVN, the uploaded SRPM must look like @<svn rev>:$srpm_name-<version>-<release>.src.rpm (created with getsrpm-mdk $srpm_name)";
	} else  {
	    print "Package $file is correct\n";
	}
    }
    return
}

sub simple_prompt {
    my $cred = shift;
    my $realm = shift;
    my $default_username = shift;
    my $may_save = shift;
    my $pool = shift;

    print "Enter authentication info for realm: $realm\n";
    print "Username: ";
    my $username = <>;
    chomp($username);
    $cred->username($username);
    print "Password: ";
    my $password = <>;
    chomp($password);
    $cred->password($password);
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
