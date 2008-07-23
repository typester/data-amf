use inc::Module::Install;
name 'Data-AMF';
all_from 'lib/Data/AMF.pm';

test_requires 'Test::More';

requires 'perl' => '5.008001';
requires 'Moose';
requires 'Scalar::Util';

use_test_base;
auto_include;
WriteAll;
