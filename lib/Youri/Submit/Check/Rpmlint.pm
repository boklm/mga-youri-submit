# $Id$
package Youri::Submit::Check::Rpmlint;

=head1 NAME

Youri::Submit::Check::Rpmlint - Rpmlint-based check

=head1 DESCRIPTION

This check plugin wraps rpmlint, and reject packages triggering results
declared as fatal.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Check/;

=head2 new(%args)

Creates and returns a new Youri::Submit::Check::Rpmlint object.

Specific parameters:

=over

=item results $results

List of rpmlint result id considered as fatal.

=item path $path

Path to the rpmlint executable (default: /usr/bin/rpmlint)

=item config $config

Specific rpmlint configuration.

=back

=cut


sub _init {
    my $self   = shift;
    my %options = (
        results  => undef,
        path   => '/usr/bin/rpmlint',
        config => '',
        @_
    );

    croak "no results to check" unless $options{results};
    croak "fatal should be an arrayref" unless ref $options{results} eq 'ARRAY';

    $self->{_config} = $options{config};
    $self->{_path} = $options{path};
    $self->{_pattern} = '^(?:' . join('|', @{$options{results}}) . ')$';
}

sub run {
    my ($self, $package, $_repository, $_target, $_define) = @_;
    croak "Not a class method" unless ref $self;

    my @errors;

    my $command = "$self->{_path} -f $self->{_config} " . $package->as_file;
    open(my $RPMLINT, "$command |") or die "Can't run $command: $!";
    while (my $line = <$RPMLINT>) {
	$line =~ /^[EW]: \S+ (\S+)(.*)$/ # old rpmlint format
	  || $line =~ /^\S+: [EW]: (\S+)(.*)$/ or next; # new rpmlint format
        my ($id, $value) = ($1, $2);
        if ($id =~ /$self->{_pattern}/o) {
            push(@errors, "$id$value");
        }
    }

    return @errors;
}
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
