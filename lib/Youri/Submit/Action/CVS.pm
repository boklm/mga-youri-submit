# $Id$
package Youri::Submit::Action::CVS;

=head1 NAME

Youri::Submit::Action::CVS - CVS versionning

=head1 DESCRIPTION

This action plugin ensures CVS versionning of package sources.

=cut

use warnings;
use strict;
use Carp;
use Cwd;
use File::Temp qw/tempdir/;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        exclude => '\.(tar(\.(gz|bz2))?|zip)$',
        perms   => 644,
        @_
    );

    $self->{_exclude} = $options{exclude};
    $self->{_perms}   = $options{perms};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    return unless $package->is_source();

    my $name    = $package->get_name();
    my $version = $package->get_version();
    my $release = $package->get_release();

    my $root = $repository->get_version_root();
    my $path = $repository->get_version_path($package, $target, $define);

    # remember original directory
    my $original_dir = cwd();

    # get a safe temporary directory
    my $dir = tempdir( CLEANUP => 1 );
    chdir $dir;

    # first checkout base directory only
    system("cvs -Q -d $root co -l $path");

    # try to checkout package directory
    my $dest = $path . '/' . $name;
    system("cvs -Q -d $root co $dest");

    # create directory if previous import failed
    unless (-d $dest) {
        print "adding directory $dest\n" if $self->{_verbose};
        system("install -d -m " . ($self->{_perms} + 111) . " $dest");
        system("cvs -Q -d $root add $dest");
    }

    chdir $dest;

    # remove all files
    unlink grep { -f } glob '*';

    # extract all rpm files locally
    $package->extract();

    # remove excluded files
    if ($self->{_exclude}) {
        unlink grep { -f && /$self->{_exclude}/ } glob '*'; 
    }

    # uncompress all compressed files
    system("bunzip2 *.bz2 2>/dev/null");
    system("gunzip *.gz 2>/dev/null");

    my (@to_remove, @to_add, @to_add_binary);
    foreach my $line (`cvs -nq update`) {
        if ($line =~ /^\? (\S+)/) {
            if (-B $1) {
                push(@to_add_binary, $1);
            } else {
                push(@to_add, $1);
            }
        }
        if ($line =~ /^U (\S+)/) {
            push(@to_remove, $1);
        }
    }
    if (@to_remove) {
        my $to_remove = join(' ', @to_remove);
        print "removing file(s) $to_remove\n" if $self->{_verbose};
        system("cvs -Q remove $to_remove");
    }
    if (@to_add) {
        my $to_add = join(' ', @to_add);
        print "adding text file(s) $to_add\n" if $self->{_verbose};
        system("cvs -Q add $to_add");
    }
    if (@to_add_binary) {
        my $to_add_binary = join(' ', @to_add_binary);
        print "adding binary file(s) $to_add_binary\n" if $self->{_verbose};
        system("cvs -Q add -kb $to_add_binary");
    }

    print "committing current directory\n" if $self->{_verbose};
    system("cvs -Q commit -m $version-$release") unless $self->{_test};

    # tag new release
    my $tag = "r$version-$release";
    $tag =~ s/\./_/g;
    print "tagging current directory as $tag\n" if $self->{_verbose};
    system("cvs -Q tag $tag") unless $self->{_test};

    # get back to original directory
    chdir $original_dir;

}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
