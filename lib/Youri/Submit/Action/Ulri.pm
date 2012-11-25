# $Id$
package Youri::Submit::Action::Ulri;

=head1 NAME

Youri::Submit::Action::Ulri - Runs ulri on the upload host

=head1 DESCRIPTION

This action plugin runs ulri to try starting a build

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
	uphost => '',
	user => '',
	ssh_key => '',
	logfile => '',
	verbose => '',
        @_
    );
    croak "undefined upload host" unless $options{uphost};
    croak "undefined ssh key" unless $options{ssh_key};

    foreach my $var ('user', 'uphost', 'ssh_key', 'logfile', 'verbose') {
	$self->{"_$var"} = $options{$var};
    }

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $remotecmd = "ulri";
    if ($self->{_logfile}) {
	$remotecmd = "ULRI_LOG_FILE=$self->{_logfile} " . $remotecmd;
    }
    my $cmd = "ssh -i $self->{_ssh_key} $self->{_user}\@$self->{_uphost} $remotecmd";
    print "Submit::Action::Ulri: doing $cmd\n" if $self->{_verbose};
}
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2012, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
