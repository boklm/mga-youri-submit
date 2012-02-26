# $Id$
package Youri::Submit::Check::ACL;

=head1 NAME

Youri::Submit::Check::Tag - Incorrect tag values check

=head1 DESCRIPTION

This check plugin rejects packages with incorrect tag values, based on regular
expressions.

=cut

use strict;
use Carp;
use base qw/Youri::Submit::Check/;
my $acl;

sub _init {
    my $self   = shift;
    my %options = (
	acl_file => '',
        @_
    );
    $acl = get_acl($options{acl_file});
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $file = $package->get_full_name();
    my $arch = $package->get_arch();
    my $srpm = $package->get_canonical_name;
    my $section = $repository->_get_section($package, $target, $define);
    my $user = $define->{user};
    foreach my $t (keys %$acl) {
	next if $target !~ /$t/;
	foreach my $acl (@{$acl->{$t}}) {
	    my ($a, $media, $r, $users) = @$acl;
	    next if $arch !~ $a || $srpm !~ $r || $section !~ $media;
	    if ($user =~ /$users/) {
		return 
	    } else { 
		return "$user is not authorized to upload packages belonging to $srpm in section $section (authorized persons: " . join(', ', split '\|',  $users) . ")";
	    }
	}
    }
    return
}

sub get_acl {
    my ($file) = @_;
    my %acl;
    open my $f, $file;
    while (<$f>) { 
	my ($dis, $arch, $media, $regexp, $users) = split ' ';
	push @{$acl{$dis}}, [ $arch , $media, $regexp, $users ]
    }
    \%acl
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
