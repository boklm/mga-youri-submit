# $Id$
package Youri::Submit::Post::CleanRpmsrate;

=head1 NAME

Youri::Submit::Post::CleanRpmsrate - calls clean-rpmsrate

=head1 DESCRIPTION

Calls clean-rpmsrate

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Post/;

#- inlined from MDK::Common::DataStructure
sub uniq { my %l; $l{$_} = 1 foreach @_; grep { delete $l{$_} } @_ }

sub _init {
}

sub run {
    my ($self, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $root = $repository->get_install_root();
    my @changed = @{$repository->get_arch_changed($target)};
    if (grep { $_ eq 'i586' } @changed) {
	# x86_64 uses i586 pkgs, so rpmsrate need to be rebuild
	@changed = uniq(@changed, 'x86_64');
    }
    foreach my $arch (@changed) {
	my $rpmsrate = "$root/$target/$arch/media/media_info/rpmsrate";
	# FIXME: have a method to get core/release instead of hardcoding it
	my @media = "$root/$target/$arch/media/core/release";
	system("clean-rpmsrate", "-o", "$rpmsrate-new", "$rpmsrate-raw", @media);
	# FIXME: unlink instead of mv if the content did not change
	system("mv", "-f", "$rpmsrate-new", $rpmsrate);
    }
    return
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Mandriva <blino@mandriva.com>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;

