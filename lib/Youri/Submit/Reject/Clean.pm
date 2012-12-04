# $Id$
package Youri::Submit::Reject::Clean;

=head1 NAME

Youri::Submit::Action::Clean - Old revisions cleanup

=head1 DESCRIPTION

This action plugin ensures cleanup of old package revisions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Reject/;

sub run {
    my ($self, $package, $errors, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $file = $package->as_file();
    print "deleting file $file\n" if $self->{_verbose};
    unlink $file unless $self->{_test};
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1
