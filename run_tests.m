function run_tests()
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'model'),fullfile(root,'tests'));
if ~exist(fullfile(root,'results'),'dir'); mkdir(fullfile(root,'results')); end
diary(fullfile(root,'results','tests.txt')); cleaner=onCleanup(@() diary('off'));
test_physics;
test_scheduling;
test_resolution;
fprintf('All tests passed under %s.\n',version);
end
