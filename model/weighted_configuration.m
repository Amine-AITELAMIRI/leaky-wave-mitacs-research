function [value,row,pairs] = weighted_configuration(rates,user_weights)
% Linear assignment is exact after fixing the active bands and ports.
weighted=rates.*reshape(user_weights,1,1,[]);
upper=sum(max(weighted,[],3),2);
[upper,order]=sort(upper,'descend');
value=-Inf; row=0; pairs=[];
for i=1:numel(order)
    if upper(i)<=value+1e-11; break; end
    candidate=order(i);
    R=reshape(weighted(candidate,:,:),size(rates,2),size(rates,3));
    [score,chosen]=solve_assignment(R);
    if score>value
        value=score; row=candidate; pairs=chosen;
    end
end
end
