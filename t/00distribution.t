#!/usr/bin/perl
# $Id: 00distribution.t 1723 2006-10-17 13:53:27Z warly $

use Test::More;

BEGIN {
    eval {
        require Test::Distribution;
    };
    if($@) {
        plan skip_all => 'Test::Distribution not installed';
    } else {
        import Test::Distribution only => [ qw/use pod description/ ];
    }
}
