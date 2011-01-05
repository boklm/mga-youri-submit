# $Id: Base.pm 631 2006-01-26 22:22:23Z guillomovitch $
package Youri::Submit::Check;

=head1 NAME

Youri::Submit::Check - Abstract check plugin

=head1 DESCRIPTION

This abstract class defines check plugin interface.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Plugin/;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
