function run_experiments(smoke)
if nargin<1; smoke=false; end
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'model'),fullfile(root,'experiments'));
out=fullfile(root,'results'); if smoke; out=fullfile(out,'smoke'); end
if ~exist(out,'dir'); mkdir(out); end
diary(fullfile(out,'execution.txt')); cleaner=onCleanup(@() diary('off'));
p=parameters();
geometry_study(p,out);
headline_study(p,out,smoke);
convergence_study(p,out,smoke);
fairness_study(p,out,smoke);
localization_study(p,out,smoke);
fprintf('All predefined studies completed. No trial count was chosen from the results.\n');
end
