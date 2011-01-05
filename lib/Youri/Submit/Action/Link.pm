# $Id: Link.pm 233641 2008-01-31 16:35:55Z pixel $
package Youri::Submit::Action::Link;

=head1 NAME

Youri::Submit::Action::Link - Noarch packages linking

=head1 DESCRIPTION

This action plugin ensures linking of noarch packages between arch-specific
directories.

=cut

use warnings;
use strict;
use Carp;
use Cwd;
use File::Spec;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        symbolic => 0, # use symbolic linking
        @_
    );

    $self->{_symbolic} = $options{symbolic};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    # only needed for noarch packages
    return unless $package->get_arch() eq 'noarch';

    my $default_dir = $repository->get_install_dir($package, $target, $define);
    my $file = $package->get_file_name();

    # FIXME remove prefix this should be done by a function
    $file =~ s/^\d{14}\.\w*\.\w+\.\d+_//;
    $file =~ s/^\@\d+://;

    foreach my $arch ($repository->get_extra_arches()) {
        # compute installation target, forcing arch
        my $other_dir = $repository->get_install_dir(
            $package,
            $target,
            $define,
            { arch => $arch }
        );

        if (! $self->{_test}) {
            my $current_dir = cwd();
            chdir $other_dir;
            my $default_file = File::Spec->abs2rel($default_dir) . '/' . $file;
            if ($self->{_symbolic}) {
                symlink $default_file, $file;
            } else {
                link $default_file, $file;
            }
            chdir $current_dir;
	    print "set_install_dir_changed($other_dir) for updated $file\n";
	    $repository->set_install_dir_changed($other_dir);
	    $repository->set_arch_changed($target, $arch);
        }
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
