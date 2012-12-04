# $Id$
package Youri::Submit::Check::Host;

=head1 NAME

Youri::Submit::Check::Tag - Incorrect tag values check

=head1 DESCRIPTION

This check plugin rejects packages with incorrect tag values, based on regular
expressions.

=cut

use strict;
use Carp;
use base qw/Youri::Submit::Check/;
my $host;

sub _init {
    my $self   = shift;
    my %options = (
	host_file => '',
        @_
    );
    $host = get_host($options{host_file})
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $file = $package->as_file;
    my $arch = $package->get_arch;
    my $buildhost = $package->as_formated_string('%{buildhost}');
    foreach my $h (keys %$host) {
	next if $buildhost !~ $h;
	if ($arch =~ $host->{$h}) {
	    return
	}
    }
    "Packages build on host $buildhost are not authorized for arch $arch";
}

sub get_host {
    my ($file) = @_;
    my %host;
    open my $f, $file;
    while (<$f>) { 
	my ($host, $arch) = split ' ';
	$host{$host} = $arch
    }
    \%host
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
