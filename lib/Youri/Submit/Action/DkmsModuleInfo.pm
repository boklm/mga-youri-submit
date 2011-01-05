# $Id$
package Youri::Submit::Action::DkmsModuleInfo;

=head1 NAME

Youri::Submit::Action::DkmsModuleInfo - extract and commit info from dkms package.

=head1 DESCRIPTION

This action plugin extract modalias and description from dkms packages and commit them
on a SVN module.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;
use File::Temp qw/tempdir/;
use File::Basename;
use SVN::Client;

#- inlineed from MDK::Common::Various
sub chomp_ { my @l = @_; chomp @l; wantarray() ? @l : $l[0] }

sub _init {
    my ($self, %options) = @_;

    croak "undefined svn module" unless $options{svn_module};

    foreach my $var ('svn_module') {
	$self->{"_$var"} = $options{$var};
    }

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my ($dkms_name) = $package->get_canonical_name =~ /^dkms-(.*)$/ or return;
    my $package_name = $package->get_name;
    my ($kver) = $package_name =~ /^$dkms_name-kernel-(.*)$/ or return;

    my @files = map { $_->[0] } $package->get_files;
    my @module_files = grep { m!^(/lib/modules/|/var/lib/dkms-binary/).*\.ko(\.gz)?$! } @files
      or return;

    print "Submit::Action::DkmsModuleInfo: proceeding with $package_name\n" if $self->{_verbose};

    my $tempdir = tempdir(CLEANUP => 1);
    my $file = $package->as_file;
    my $cmd = "rpm2cpio $file | (cd $tempdir ; cpio --quiet -id)";
    print "Submit::Action::DkmsModuleInfo: doing $cmd\n" if $self->{_verbose};
    if (system($cmd) != 0) {
	print "Submit::Action::DkmsModuleInfo: failed!\n" if $self->{_verbose};
	return;
    }

    my @fields = qw(description alias);

    my (%modules);
    foreach my $file (@module_files) {
        print "Submit::Action::DkmsModuleInfo: extracting $file\n" if $self->{_verbose};
        my $module = $file;
        $module =~ s!.*/!!;
        $module =~ s!\.ko(\.gz)$!!;
        $modules{$module}{$_} = [ chomp_(`/sbin/modinfo -F $_ $tempdir$file`) ]
          foreach @fields;
    }

    eval {
        my $svn = SVN::Client->new();
        my $dir = $tempdir . '/' . basename($self->{_svn_module});
        my $revision = $svn->checkout($self->{_svn_module}, $dir, 'HEAD', 0);
        my $vdir = $dir . '/' . $kver;
        $svn->update($vdir, 'HEAD', 0);
        -d $vdir or $svn->mkdir($vdir);
        foreach my $module (keys %modules) {
            print "Submit::Action::DkmsModuleInfo: adding module $module\n" if $self->{_verbose};
            foreach my $field (@fields) {
                my $file = "$vdir/$module.$field";
                $svn->update($file, 'HEAD', 0);
                my $exists = -f $file;
                open(my $fh, ">", $file);
                print $fh map { "$_\n" } @{$modules{$module}{$field}};
                $svn->add($file, 1) if !$exists;
            }
        }

        $svn->log_msg(sub { $_[0] = \"add dkms info for $dkms_name with kernel $kver" });
        $svn->commit($vdir, 0);
    };
    if (my $error = $@) {
	print "Submit::Action::DkmsModuleInfo: commit to svn failed ($error)!\n" if $self->{_verbose};
	return;
    }

    1;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
