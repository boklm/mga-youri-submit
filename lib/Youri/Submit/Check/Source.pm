# $Id$
package Youri::Submit::Check::Source;

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
        @_
    );
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;
    my $file = $package->as_file();
    if (!$package->is_source()) {
        return "Package $file is not a source rpm";
    }
    return
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
