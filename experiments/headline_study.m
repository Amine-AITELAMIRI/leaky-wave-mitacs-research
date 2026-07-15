function result = headline_study(p,out,smoke)
N_list=[2 3 5 8 12 20 30]; isolation=[0 20 44 Inf]; trials=100;
if smoke; trials=2; end
rng(p.seed); users=rand(trials,max(N_list))*120-60;
rate=zeros(trials,numel(N_list),4,2); active=zeros(trials,numel(N_list),4,2);
passes=zeros(trials,numel(N_list),4);
catalog=port_catalog(p.K);
for tr=1:trials
    H=port_response(p.f,users(tr,:),p);
    for ni=1:numel(N_list)
        h=H(:,:,1:N_list(ni));
        for ii=1:4
            [rate(tr,ni,ii,1),s]=selected_schedule(h,p,isolation(ii),catalog);
            [rate(tr,ni,ii,2),c]=coherent_schedule(h,p,isolation(ii),s);
            active(tr,ni,ii,:)=[sum(s.users>0),sum(c.users>0)];
            passes(tr,ni,ii)=c.passes;
            assert(rate(tr,ni,ii,2)>=rate(tr,ni,ii,1)-1e-8);
        end
    end
    fprintf('Headline trial %d/%d\n',tr,trials);
end
assert(all(diff(rate(:,:,:,1),1,2)>=-1e-8,'all'));
assert(all(diff(rate(:,:,:,1),1,3)>=-1e-8,'all'));
snr=[0 10 20 30 40 50]; sensitivity=zeros(trials,numel(snr),3);
b=benchmarks(p);
for tr=1:trials
    H=port_response(p.f,users(tr,:),p);
    for si=1:numel(snr)
        q=p; q.noise=p.P*b.matched_gain/10^(snr(si)/10); qb=benchmarks(q);
        for ii=1:3
            sensitivity(tr,si,ii)=100*selected_schedule(H,q,isolation(ii+1),catalog)/qb.matched_Mbps;
        end
    end
end
result=struct('p',p,'N',N_list,'isolation',isolation,'trials',trials,'theta',users, ...
    'rate',rate,'active',active,'passes',passes,'reference',b,'snr',snr,'sensitivity',sensitivity);
fprintf('N30 selected/coherent means (rows isolation):\n');
disp(reshape(mean(rate(:,end,:,:),1),4,2));
save_result(out,'headline',result);
end
