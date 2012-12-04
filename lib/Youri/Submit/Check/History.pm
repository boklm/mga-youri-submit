# $Id$
package Youri::Submit::Check::History;

=head1 NAME

Youri::Submit::Check::History - Non-linear history check

=head1 DESCRIPTION

This check plugin rejects packages whose history does not include last
available revision one.

=cut

use warnings;
use strict;
use Carp;
use Youri::Package;
use base qw/Youri::Submit::Check/;

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my @errors;

    my $last_revision =
        $repository->get_last_older_revision($package, $target, $define);
    
    if ($last_revision) {
        # skip the test if last revision has been produced from another source package, as it occurs during package split/merges
        return 
            if $last_revision->get_canonical_name()
            ne $package->get_canonical_name();
    
        my ($last_revision_number) = $last_revision->get_last_change()->[Youri::Package::CHANGE_AUTHOR] =~ /(\S+)\s*$/;
        my %entries =
            map { $_ => 1 }
            map { /(\S+)\s*$/ }
            map { $_->[Youri::Package::CHANGE_AUTHOR] }
            $package->get_changes();
        unless ($entries{$last_revision_number}) {
            push(
                @errors,
                "Last changelog entry $last_revision_number from last revision " . $last_revision->as_string() . "  missing from current changelog"
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
