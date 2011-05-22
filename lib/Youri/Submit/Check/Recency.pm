# $Id: Recency.pm 224793 2007-07-08 02:44:48Z spuk $
package Youri::Submit::Check::Recency;

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

    my @errors;

    my @revisions = $repository->get_revisions($package, $target, $define, undef, sub { return $_[0]->compare($package) >= 0 });
    if (@revisions) {
        my $section = $repository->_get_section($package, $target, $define);
        push(
            @errors,
            "Current or newer revision(s) already exists in $section for $target: " .
                join(', ', @revisions)
        );
    }

    my $defined_section = $define->{section};

    #FIXME We only search requested section to allow manual upload to multiple sections
    # until the code handles it.

    return @errors;

    # if the user provided a section, check also in the default section
    if ($defined_section) {
        $define->{section} = undef;
        my @default_revisions = $repository->get_revisions($package, $target, $define, undef, sub { return $_[0]->compare($package) >= 0 });
        if (@default_revisions) {
            my $section = $repository->_get_section($package, $target, $define);
            push(
                @errors,
                "Current or newer revision(s) already exists in $section for $target: " .
                    join(', ', @default_revisions)
            );
        }
        $define->{section} = $defined_section;
    }

    return @errors;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
