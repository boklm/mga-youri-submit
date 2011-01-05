# $Id: Bugzilla.pm 1700 2006-10-16 12:57:42Z warly $
package Youri::Submit::Action::Bugzilla;

=head1 NAME

Youri::Submit::Action::Bugzilla - Bugzilla synchronisation

=head1 DESCRIPTION

This action plugin ensures synchronisation with Bugzilla.

=cut

use warnings;
use strict;
use Carp;
use Youri::Bugzilla;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        host    => '',
        base    => '',
        user    => '',
        pass    => '',
        contact => '',
        @_
    );

    $self->{_bugzilla} = Youri::Bugzilla->new(
        $options{host},
        $options{base},
        $options{user},
        $options{pass}
    );
    $self->{_contact}  = $options{contact};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    return unless $package->is_source();

    my $name     = $package->get_name();
    my $version  = $package->get_version();
    my $summary  = $package->get_summary();
    my $packager = $package->get_packager();
    $packager =~ s/.*<(.*)>/$1/;

    if ($self->{_bugzilla}->has_package($name)) {
        my %versions =
            map { $_ => 1 }
            $self->{_bugzilla}->get_versions($name);
        unless ($versions{$version}) {
            print "adding version $version to bugzilla\n" if $self->{_verbose};
            $self->{_bugzilla}->add_version($name, $version)
                unless $self->{_test};
        }
    } else {
        print "adding package $name to bugzilla\n" if $self->{_verbose};
        $self->{_bugzilla}->add_package(
            $name,
            $summary,
            $version,
            $packager,
            $self->{_contact}
        ) unless $self->{_test};
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
