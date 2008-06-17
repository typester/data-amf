use inc::Module::Install;
name 'Data-AMF';
all_from 'lib/Data/AMF.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
