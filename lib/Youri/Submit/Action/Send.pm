# $Id$
package Youri::Submit::Action::Send;

=head1 NAME

Youri::Submit::Action::Send - upload package

=head1 DESCRIPTION

This action plugin uploads the package on uphost

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
	keep_svn_release => '',
        @_
    );
    croak "undefined upload host" unless $options{uphost};
    croak "undefined ssh key" unless $options{ssh_key};

    foreach my $var ('perms', 'user', 'uphost', 'ssh_key', 'verbose', 'keep_svn_release') {
	$self->{"_$var"} = $options{$var};
    }

    return $self;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $file = $package->as_file();
    my $dest = $repository->get_upload_dir($package, $target, $define);

    print "Sending file $file to $dest\n" if $self->{_verbose};
    my $base;
    if ($self->{_keep_svn_release}) {
	$base = basename($file)
    } else {
	($base) = $file =~ /.*\/(?:@\d+:)?([^\/]*)/
    }

    my $cmd = "scp -i $self->{_ssh_key} $file $self->{_user}\@$self->{_uphost}:/$dest$base.new";
    my $cmd2 = "ssh -i $self->{_ssh_key} $self->{_user}\@$self->{_uphost} \"mv /$dest$base.new /$dest$base\"";
    print "Submit::Action::Send: doing $cmd\n$cmd2\n" if 1 || $self->{_verbose};
    if (!$self->{_test}) {
	if (!system($cmd)) {
	    if (!system($cmd2)) {
		print "Submit::Action::Send: upload succeeded!\n";
		return 1
	    }
	}
	print "Submit::Action::Send: upload failed!\n";
    }
}
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
