function [total,pairs] = solve_assignment(rate)
% Same cost transformation as the archive's solve_rate_assignment.
if isempty(rate)
    total=0; pairs=zeros(0,2); return
end
assert(all(isfinite(rate),'all') && all(rate>=0,'all'));
[best,user] = max(rate,[],2);
if size(rate,1)<=size(rate,2) && numel(unique(user))==size(rate,1)
    pairs=[(1:size(rate,1)).',user]; total=sum(best); return
end
cost = max(rate(:))-rate;
unmatched = max(cost(:))+max(1,max(abs(cost(:))));
pairs = matchpairs(cost,unmatched,'min');
total = sum(rate(sub2ind(size(rate),pairs(:,1),pairs(:,2))));
end
