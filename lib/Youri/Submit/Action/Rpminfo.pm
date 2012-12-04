# $Id$
package Youri::Submit::Action::Rpminfo;

=head1 NAME

Youri::Submit::Action::RpmInfo - Creates .info files

=head1 DESCRIPTION

This action plugin ensures the creation of .info files

=cut

use warnings;
use strict;
use Carp;
use File::Basename;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        perms => 644,
	uphost => '',
	user => '',
	ssh_key => '',
	verbose => '',
        @_
    );
    croak "undefined upload host" unless $options{uphost};
    croak "undefined ssh key" unless $options{ssh_key};

    foreach my $var ('perms', 'user', 'uphost', 'ssh_key', 'verbose') {
	$self->{"_$var"} = $options{$var};
    }

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $file = $package->as_file();
    my $dest = $repository->get_upload_dir($package, $target, $define);

    print "Caching rpm information $file on $dest\n" if $self->{_verbose};
    my $base = basename ($file);
    $dest =~ s/\/[0-9]{14}\./\/*./;

    my $cmd = "ssh -i $self->{_ssh_key} $self->{_user}\@$self->{_uphost} \"srpm=`echo /$dest$base`; rpm -q --qf '\%{name}\n\%{epoch}\n\%{version}-\%{release}\n\%{summary}\n' -p \\\$srpm > \\\$srpm.info\"";
    print "Submit::Action::RpmInfo: doing $cmd\n" if $self->{_verbose};
    if (!$self->{_test}) {
	if (!system($cmd)) {
		print "Submit::Action::RpmInfo: rpminfo succeeded!\n";
		return 1
	}
	print "Submit::Action::RpmInfo: rpminfo failed!\n";
    }
}
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
