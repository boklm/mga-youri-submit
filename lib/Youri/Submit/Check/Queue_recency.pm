# $Id: Queue_recency.pm 4747 2007-01-30 10:02:41Z pixel $
package Youri::Submit::Check::Queue_recency;

=head1 NAME

Youri::Submit::Check::Recency - Release check against current target

=head1 DESCRIPTION

This check plugin rejects packages whose a current or newer revision already
exists for current upload target.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my @newer_revisions = 
        $repository->get_upload_newer_revisions($package, $target, $define);
    if (@newer_revisions) {
        return "Newer revisions already exists for $target in upload queue: " . join(', ', @newer_revisions);
    }
    return
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
