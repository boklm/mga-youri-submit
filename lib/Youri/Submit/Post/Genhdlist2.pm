# $Id: Gendistrib.pm 115367 2007-01-30 09:47:04Z pixel $
package Youri::Submit::Post::Genhdlist2;

=head1 NAME

Youri::Submit::Post::Genhdlist2 - calls genhdlist2

=head1 DESCRIPTION

Calls genhdlist2

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Post/;

sub _init {
    my $self   = shift;
    my %options = (
        user => '',
	host  => '',
	source => '',
	destination => '',
        @_
    );

    foreach my $var ('command') {
	$self->{"_$var"} = $options{$var};
    }
}

sub run {
    my ($self, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $root = $repository->get_install_root();
    my @changed = @{$repository->get_install_dir_changed($target)};
    if (!@changed) {
	print "nothing to do\n";
	return;
    }
    foreach my $dir (@changed) {
	my $file_deps = "$dir/../../media_info/file-deps";
	my $file_deps_option = -e $file_deps ? "--file-deps $file_deps" : '';
	my $cmd = "time $self->{_command} -v --versioned --allow-empty-media $file_deps_option $dir";
	print "$cmd\n";
	system($cmd) == 0 or print "ERROR: $cmd failed\n";
    }

    # need to redo global MD5SUM. This MD5SUM is mostly obsolete, but is still needed up to 2007.1
    # (and even on cooker for existing urpmi.cfg)
    foreach my $arch (@{$repository->get_arch_changed($target)}) {
	my $dir = "$root/$target/$arch/media/media_info";
	my $cmd = "cd $dir ; time md5sum hdlist_* synthesis.*";
	print "$cmd\n";
	my $m = `$cmd`;
	open my $f, '>', "$dir/MD5SUM" or die "Can't write $dir/MD5SUM: $!\n";
	print $f $m;

	{
	    require MDV::Distribconf::Build;
	    my $distrib = MDV::Distribconf::Build->new("$root/$target/$arch");
	    $distrib->loadtree or die "$root/$target/$arch does not seem to be a distribution tree\n";
	    $distrib->parse_mediacfg;
	    $distrib->write_version($distrib->getfullpath(undef, "VERSION"));
	    print "updated $root/$target/$arch/VERSION\n";
	}
    }
    return;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, Mandriva <warly@mandriva.com>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;

