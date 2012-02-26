# $Id$
package Youri::Submit::Action::Clean;

=head1 NAME

Youri::Submit::Action::Clean - Old revisions cleanup

=head1 DESCRIPTION

This action plugin ensures cleanup of old package revisions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    foreach my $replaced_package (
        $repository->get_replaced_packages($package, $target, $define)
    ) {
        my $file = $replaced_package->as_file();
        print "deleting file $file\n" if $self->{_verbose};
        unlink $file unless $self->{_test};
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
