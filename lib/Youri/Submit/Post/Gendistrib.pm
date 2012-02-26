# $Id$
package Youri::Submit::Post::Gendistrib;

=head1 NAME

Youri::Submit::Post::Gendistrib - calls gendistrib

=head1 DESCRIPTION

Calls gendistrib

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

    foreach my $var ('tmpdir', 'command') {
	$self->{"_$var"} = $options{$var};
    }
}

sub run {
    my ($self, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $root = $repository->get_install_root();
    (undef, undef, my $hour) = gmtime(time);
    # during the night, use complete hdlist rebuild
    my $fast = '--fast';
    $fast = ''; # blino: don't use fast for now, it might be broken
    if ($hour > 22 && $hour < 5) {
	if ($hour < 4) {
	    $fast = '--blind'
	} else {
	    $fast = ''
	}
    }
    foreach my $arch (@{$repository->get_arch_changed($target)}) {
	my $cmd = "TMPDIR=$self->{_tmpdir}/$target/$arch time $self->{_command} --nochkdep --nobadrpm $fast --noclean $root/$target/$arch";
	print "$cmd\n";
	system($cmd);
    }
    return
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, Mandriva <warly@mandriva.com>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;

