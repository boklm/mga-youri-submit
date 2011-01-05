# $Id: Unpack.pm 115370 2007-01-30 09:59:07Z pixel $
package Youri::Submit::Action::Unpack;

=head1 NAME

Youri::Submit::Action::Unpack - unpack package files

=head1 DESCRIPTION

This action plugin unpack package files somewhere.
When unpack_inside_distribution_root is set, dest_directory is relative to the distribution root.
When the package is a noarch, the wanted files are unpacked in distribution root of each archs.

=cut

use warnings;
use strict;
use Carp;
use File::Temp qw/tempdir/;
use base qw/Youri::Submit::Action/;

sub _init {
    my ($self, %options) = @_;

    croak "undefined package name" unless $options{name};
    croak "undefined source sub directory" unless $options{source_subdir};
    croak "undefined destination directory" unless $options{dest_directory};

    foreach my $var ('name', 'dest_directory', 'source_subdir', 'grep_files', 'unpack_inside_distribution_root') {
	$self->{"_$var"} = $options{$var};
    }

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    $package->get_name eq $self->{_name} or return;

    my @dests = $self->{_unpack_inside_distribution_root} ? 
	(map { "$_/$self->{_dest_directory}" } $repository->get_distribution_roots($package, $target))
	: $self->{_dest_directory};
    my $file = $package->as_file;
    print "Unpacking rpm $file$self->{_source_subdir} to @dests\n" if $self->{_verbose};

    my $tempdir = tempdir(CLEANUP => 1);

    my $cmd = "rpm2cpio $file | (cd $tempdir ; cpio -id)";
    print "Submit::Action::Unpack: doing $cmd\n" if $self->{_verbose};
    if (!$self->{_test} && system($cmd) != 0) {
	print "Submit::Action::Unpack: failed!\n" if $self->{_verbose};
	return;
    }

    foreach my $dest (@dests) {
	my $find_grep = $self->{_grep_files} ? "find | grep '$self->{_grep_files}'" : 'find';
	my $cmd = "cd $tempdir/$self->{_source_subdir}; $find_grep | cpio -pdu $dest";
	print "Submit::Action::Unpack: doing $cmd\n" if $self->{_verbose};
	if (!$self->{_test}) {
	    my @l = glob("$tempdir/$self->{_source_subdir}");
	    if (@l == 1 && -d $l[0]) {
		if (system($cmd) != 0) {
		    print "Submit::Action::Unpack: failed!\n" if $self->{_verbose};
		}
	    } else {
		print "Submit::Action::Unpack: directory $self->{_source_subdir} doesn't exist in package $self->{_name}\n";
	    }
	}
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
