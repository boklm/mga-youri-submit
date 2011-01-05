# $Id: Precedence.pm 1707 2006-10-16 16:26:42Z warly $
package Youri::Submit::Check::Precedence;

=head1 NAME

Youri::Submit::Check::Precedence - Release check against another check

=head1 DESCRIPTION

This check plugin rejects packages whose an older revision already exists for
another upload target.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

sub _init {
    my $self   = shift;
    my %options = (
        _target => undef, # mandatory targets
        @_
    );

    die "undefined target" unless $options{target};

    $self->{_target} = $options{target};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my @errors;

    my @older_revisions = 
        $repository->get_older_revisions($package, $self->{_target}, $define);
    if (@older_revisions) {
        push(
            @errors,
            "Older revisions still exists for $self->{_target}: " . join(', ', @older_revisions)
        );
    }

    return @errors;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
