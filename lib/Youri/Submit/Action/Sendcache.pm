# $Id: Sendcache.pm 232350 2007-12-07 18:26:17Z spuk $
package Youri::Submit::Action::Sendcache;

=head1 NAME

Youri::Submit::Action::Sendcache - upload package to cache

=head1 DESCRIPTION

This action plugin uploads the package on uphost

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
	uphost => '',
	user => '',
	ssh_key => '',
	verbose => '',
	root => '',
	debug_pkgs => 0,
        @_
    );
    croak "undefined upload host" unless $options{uphost};
    croak "undefined ssh key" unless $options{ssh_key};

    foreach my $var ('perms', 'user', 'uphost', 'ssh_key', 'verbose', 'root', 'debug_pkgs') {
	$self->{"_$var"} = $options{$var};
    }

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    # only cache debug packages if option debug_pkgs is true
    return if ($package->is_debug() && !$self->{_debug_pkgs});

    my $file = $package->get_file();
    my $dest = $repository->get_upload_dir($package, $target, $define);
    $dest =~ s!$repository->{_upload_root}/$repository->{_queue}!$self->{_root}!;

    print "Sending file $file to $dest\n" if $self->{_verbose};
    my $destfile = "$dest".basename($file);
    $destfile =~ s,/[^/_]+_([^/]+)$,/$1,;
    $destfile =~ s,/@\d+:,/,;
    my $destfilehidden = $destfile;
    $destfilehidden =~ s,/([^/]+)$,/.$1,;

    my $cmd = "scp -i $self->{_ssh_key} $file $self->{_user}\@$self->{_uphost}:/$destfilehidden";
    my $cmd2 = "ssh -i $self->{_ssh_key} $self->{_user}\@$self->{_uphost} \"mv /$destfilehidden /$destfile\"";
    print "Submit::Action::Send: doing $cmd\n$cmd2\n" if 1 || $self->{_verbose};
    if (!$self->{_test}) {
	if (!system($cmd)) {
	    if (!system($cmd2)) {
		print "Submit::Action::Sendcache: upload succeeded!\n";
		return 1
	    }
	}
	print "Submit::Action::Sendcache: upload failed!\n";
    }
}
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
