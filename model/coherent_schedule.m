function [total,best] = coherent_schedule(H,p,isolation,selected)
% Feasible deterministic improvement, not global beamforming optimization.
K=size(H,2); N=size(H,3);
best=selected; total=evaluate_schedule(H,best,p,isolation);
gain=reshape(sum(abs(H).^2,1),K,N);
[~,pairs]=solve_assignment(p.B/K*log2(1+p.P/min(K,N)*gain/(p.noise/K))/1e6);
seed.users=zeros(1,K); seed.weights=zeros(2,K);
for i=1:size(pairs,1)
    b=pairs(i,1); u=pairs(i,2); seed.users(b)=u;
    seed.weights(:,b)=feed_weight(H(:,b,u),3);
end
if evaluate_schedule(H,seed,p,isolation)>total
    best=seed; total=evaluate_schedule(H,best,p,isolation);
end
for pass=1:20
    old=total;
    for b=1:K
        free=setdiff(1:N,best.users(setdiff(1:K,b)));
        candidate=best; candidate.users(b)=0; candidate.weights(:,b)=0;
        value=evaluate_schedule(H,candidate,p,isolation);
        if value>total+1e-10; total=value; best=candidate; end
        for u=free
            for mode=1:3
                candidate=best; candidate.users(b)=u;
                candidate.weights(:,b)=feed_weight(H(:,b,u),mode);
                value=evaluate_schedule(H,candidate,p,isolation);
                if value>total+1e-10; total=value; best=candidate; end
            end
        end
    end
    active=find(best.users>0);
    for i=1:numel(active)
        for j=i+1:numel(active)
            b=active(i); c=active(j);
            candidate=best; candidate.users([b c])=best.users([c b]);
            for mode1=1:3
                for mode2=1:3
                    candidate.weights(:,b)=feed_weight(H(:,b,candidate.users(b)),mode1);
                    candidate.weights(:,c)=feed_weight(H(:,c,candidate.users(c)),mode2);
                    value=evaluate_schedule(H,candidate,p,isolation);
                    if value>total+1e-10; total=value; best=candidate; end
                end
            end
        end
    end
    if total<=old+1e-10; break; end
end
best.passes=pass;
best.powers=p.P*(best.users>0)/sum(best.users>0);
end
