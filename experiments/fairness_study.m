function fairness_study(p,out,smoke)
rng(2042); trials=20; intervals=1000;
if smoke; trials=2; intervals=30; end
r.config=p; r.seed=2042; r.trials=trials; r.intervals=intervals;
r.isolation=[44 Inf]; r.users=rand(trials,30)*120-60;
catalog=port_catalog(p.K,true);
r.average=zeros(trials,2,2,30); r.jain=zeros(trials,2,2);
r.stability=zeros(min(5,trials),2,3,30);
for t=1:trials
    H=port_response(p.f,r.users(t,:),p);
    for q=1:2
        rates=configuration_rates(H,p,r.isolation(q),catalog);
        [~,row,pairs]=weighted_configuration(rates,ones(1,30));
        opp=zeros(1,30);
        for i=1:size(pairs,1); opp(pairs(i,2))=rates(row,pairs(i,1),pairs(i,2)); end
        accumulated=zeros(1,30);
        horizon=intervals; if t<=5; horizon=2*intervals; end
        for slot=1:horizon
            % A fixed positive initialization prevents division by zero, not starvation.
            weights=1./(.001+accumulated/max(slot-1,1));
            [~,row,pairs]=weighted_configuration(rates,weights);
            for i=1:size(pairs,1)
                accumulated(pairs(i,2))=accumulated(pairs(i,2))+rates(row,pairs(i,1),pairs(i,2));
            end
            if slot==intervals; pf=accumulated/slot; end
            checkpoints=[floor(intervals/2) intervals 2*intervals];
            j=find(slot==checkpoints,1);
            if t<=5 && ~isempty(j); r.stability(t,q,j,:)=accumulated/slot; end
        end
        r.average(t,q,1,:)=opp; r.average(t,q,2,:)=pf;
        r.jain(t,q,1)=sum(opp)^2/(30*sum(opp.^2));
        r.jain(t,q,2)=sum(pf)^2/(30*sum(pf.^2));
    end
    fprintf('Fairness population %d/%d\n',t,trials);
end
fprintf('Fairness at 44 dB: opportunistic Jain %.4f, PF %.4f.\n',mean(r.jain(:,1,1)),mean(r.jain(:,1,2)));
save_result(out,'fairness',r);
end
