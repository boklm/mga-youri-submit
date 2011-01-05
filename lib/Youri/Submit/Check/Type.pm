# $Id: Type.pm 4747 2007-01-30 10:02:41Z pixel $
package Youri::Submit::Check::Type;

=head1 NAME

Youri::Submit::Check::Type - Type check

=head1 DESCRIPTION

This check plugin rejects packages with incorrect type.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

sub _init {
    my $self   = shift;
    my %options = (
        type => undef, # expected type
        @_
    );

    croak "no type to check" unless $options{type};
    croak "invalid type value" unless $options{type} =~ /^(?:source|binary)$/;

    $self->{_type} = $options{type};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my @errors;

    my $type = $package->get_type();
    if ($type ne $self->{_type}) {
        push(@errors, "invalid type $type");
    }

    return @errors;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
