# $Id: Rsync.pm 267280 2010-04-01 19:57:53Z bogdano $
package Youri::Submit::Pre::Rsync;

=head1 NAME

Youri::Submit::Pre::Rsync - Old revisions archiving

=head1 DESCRIPTION

This action plugin ensures archiving of old package revisions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Pre/;

sub _init {
    my $self   = shift;
    my %options = (
        user => '',
	host  => '',
	source => '',
	destination => '',
        @_
    );

    foreach my $var ('user', 'host', 'source', 'destination') {
	$self->{"_$var"} = $options{$var};
    }
}

sub run {
    my ($self, $pre_packages, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    if (system("rsync --exclude '*.new' --exclude '.*' --remove-sent-files -avlPHe 'ssh -xc arcfour' $self->{_user}\@$self->{_host}:$self->{_source}/$target/ $self->{_destination}/$target/")) {
	$self->{_error} = "Rsync command failed ($!)";
	return 
    }
    my $queue = "$self->{_destination}/$target";
    $self->{_error} = "Reading queue directory failed";
    # now get the packages downloaded
    my %packages;
    opendir my $queuedh, "$self->{_destination}/$target/" or return "Could not open $self->{_destination}/$target";
    opendir my $targetdh, $queue or return "Could not open $queue";
    my $idx;
    foreach my $media (readdir $targetdh) {
	$media =~ /^\.{1,2}$/ and next;
	print "$target - $media\n";
	if (-d "$queue/$media") {
	    opendir my $submediadh, "$queue/$media" or return "Could not open $queue/$media";
	    foreach my $submedia (readdir $submediadh) {
		$submedia =~ /^\.{1,2}$/ and next;
		print "$target - $media - $submedia\n";
		opendir my $rpmdh, "$queue/$media/$submedia" or return "Could not open $queue/$media/$submedia";
		foreach my $rpm (readdir $rpmdh) {
		    $rpm =~ /^\.{1,2}$/ and next;
		    print "$target - $media - $submedia : $rpm\n";
		    my $file = "$queue/$media/$submedia/$rpm";
		    $file =~ s/\/+/\//g;
		    if ($rpm =~ /^(\d{14}\.\w+\.\w+\.\d+)_.*\.rpm$/) {
			push @{$packages{$1}{rpms}}, { section => "$media/$submedia", file => $file };
		    } elsif ($rpm =~ /\.rpm$/) {
			$idx++;
			push @{$packages{"independant_$idx"}{rpms}}, { section => "$media/$submedia", file => $file }
		    }	
		}
	    }
	}
    }
    foreach my $key (keys %packages) {
	push @$pre_packages, $packages{$key}{rpms}
    }
    return
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, Mandriva <warly@mandriva.com>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
