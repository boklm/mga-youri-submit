# $Id: RSS.pm 1700 2006-10-16 12:57:42Z warly $
package Youri::Submit::Action::RSS;

=head1 NAME

Youri::Submit::Action::RSS - RSS notification

=head1 DESCRIPTION

This action plugin ensures RSS notification of new package revisions.

=cut

use warnings;
use strict;
use XML::RSS;
use Encode qw/from_to/;
use Carp;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        file        => '',
        title       => '',
        link        => '',
        description => '',
        charset    => 'iso-8859-1',
        max_items   => 10,
        @_
    );

    croak "undefined rss file" unless $options{file};
    croak "invalid charset $options{charset}"
        unless Encode::resolve_alias($options{charset});

    $self->{_file}        = $options{file};
    $self->{_title}       = $options{title};
    $self->{_link}        = $options{link};
    $self->{_description} = $options{description};
    $self->{_charset}    = $options{charset};
    $self->{_max_items}   = $options{max_items};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    return unless $package->is_source();

    my $subject = $package->as_formated_string('%{name}-%{version}-%{release}');
    my $content = $package->get_information();

    $content =~ s/$/<br\/>/mg;

    # ensure proper codeset conversion
    # for informations coming from package
    my $charset = $repository->get_package_charset();
    from_to($content, $charset, $self->{_charset});
    from_to($subject, $charset, $self->{_charset});

    my $rss = XML::RSS->new(
        encoding      => $self->{_charset},
        encode_output => 1
    );

    my $file = $self->{_file};
    if (-e $file) {
        $rss->parsefile($file);
        splice(@{$rss->{items}}, $self->{_max_items})
            if @{$rss->{items}} >= $self->{_max_items};
    } else {
        $rss->channel(
            title       => $self->{_title},
            link        => $self->{_link},
            description => $self->{_description},
            language    => 'en'
        );
    }

    $rss->add_item(
        title       => $subject,
        description => $content,
        mode        => 'insert'
    );

    if ($self->{_test}) {
        print $rss->as_string();
    } else {
        $rss->save($file);
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
