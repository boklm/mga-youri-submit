# $Id: Plugin.pm 4746 2007-01-30 10:01:14Z pixel $
package Youri::Submit::Plugin;

=head1 NAME

Youri::Submit::Plugin - Abstract youri-submit plugin

=head1 DESCRIPTION

This abstract class defines youri-submit plugin interface.

=cut

use warnings;
use strict;
use Carp;

=head1 CLASS METHODS

=head2 new(%args)

Creates and returns a new Youri::Submit::Plugin object.

No generic parameters (subclasses may define additional ones).

Warning: do not call directly, call subclass constructor instead.

=cut

sub new {
    my $class = shift;
    croak "Abstract class" if $class eq __PACKAGE__;

    my %options = (
        id      => '', # object id
        test    => 0,  # test mode
        verbose => 0,  # verbose mode
        @_
    );

    my $self = bless {
        _id      => $options{id},
        _test    => $options{test},
        _verbose => $options{verbose},
    }, $class;

    $self->_init(%options);

    return $self;
}

sub _init {
    # do nothing
}

=head1 INSTANCE METHODS

=head2 get_id()

Returns plugin identity.

=cut

sub get_id {
    my ($self) = @_;
    croak "Not a class method" unless ref $self;

    return $self->{_id};
}

=head2 run($package, $repository, $target, $define)

Execute action on given L<Youri::Package> object.

=head1 SUBCLASSING

The following methods have to be implemented:

=over

=item run

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
