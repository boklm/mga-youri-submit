# $Id$
package Youri::Submit::Check::Tag;

=head1 NAME

Youri::Submit::Check::Tag - Incorrect tag values check

=head1 DESCRIPTION

This check plugin rejects packages with incorrect tag values, based on regular
expressions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

sub _init {
    my $self   = shift;
    my %options = (
        tags => undef, # expected tag values
        @_
    );

    croak "no tags to check" unless $options{tags};
    croak "tag should be an hashref" unless ref $options{tags} eq 'HASH';

    $self->{_tags} = $options{tags};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my @errors;

    foreach my $tag (keys %{$self->{_tags}}) {
        my $value = $package->get_tag($tag);
        if ($value !~ /$self->{_tags}->{$tag}/) {
            push(
                @errors,
                "invalid value $value for tag $tag"
            );
        }
    }

    return @errors;

}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
