# $Id: Precedence.pm 1707 2006-10-16 16:26:42Z warly $
package Youri::Submit::Check::Section;

=head1 NAME

Youri::Submit::Check::Section - Check if package was submitted to the right section

=head1 DESCRIPTION

This check plugin rejects packages which were submitted to a section
different than the one where an older version already exists.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my @errors;

    my $submitted_main_section = $repository->_get_main_section($package, $target, $define);

    # undefine section, so that Repository::_get_section() of Mandriva_upload.pm
    # finds the section from existing packages
    my $defined_section = $define->{section};
    undef $define->{section};

    my $old_main_section = $repository->_get_main_section($package, $target, $define);
    my @older_revisions = $repository->get_older_revisions($package, $target, $define);

    # restore defined section
    $define->{section} = $defined_section;

    if (@older_revisions && $submitted_main_section ne $old_main_section) {
        push(
            @errors,
	     "Section should be $old_main_section, not $submitted_main_section."
        );
    }


    return @errors;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Mandriva

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
