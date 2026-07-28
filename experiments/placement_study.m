function placement_study(p,out,smoke,users)
rng(4042); r.config=p; r.seed=4042; r.users=users;
r.trials=size(users,1); r.input_dB=[-15 0]; r.names={'edge','uniform'};
width=.02*(p.f_max-p.f_min);
r.frequencies=[linspace(p.f_min,p.f_min+width,3) linspace(p.f_max-width,p.f_max,3);p.f];
r.rate=zeros(r.trials,2,2); r.oracle=zeros(r.trials,2);
r.crlb=zeros(r.trials,2,30); r.broadside_crlb=zeros(1,2);
grid=linspace(-90,90,1501); catalog=port_catalog(p.K);
for t=1:r.trials
    noise=(randn(2,6,30)+1j*randn(2,6,30))/sqrt(2);
    phase=2*pi*rand(1,30); delay=1e-7*rand(1,30);
    for v=1:2
        q=p; q.f=r.frequencies(v,:);
        [H,D]=port_response(q.f,users(t,:),q);
        r.oracle(t,v)=selected_schedule(H,q,44,catalog);
        r.crlb(t,v,:)=(180/pi)./sqrt(max(2*angle_information(H/sqrt(6),D/sqrt(6),'per_tone'),realmin));
        [a,da]=port_response(q.f,0,q);
        r.broadside_crlb(v)=(180/pi)/sqrt(2*angle_information(a/sqrt(6),da/sqrt(6),'per_tone'));
        scan=port_response(q.f,grid,q)/sqrt(6);
        channel=exp(1j*phase-1j*2*pi*(q.f(:)-q.f(1))*delay);
        for s=1:2
            Y=H/sqrt(6).*reshape(channel,1,6,30)+10^(-r.input_dB(s)/20)*noise;
            estimate=pilot_scan(scan,Y,grid,'per_tone');
            [~,schedule]=selected_schedule(port_response(q.f,estimate,q),q,44,catalog);
            r.rate(t,v,s)=evaluate_schedule(H,schedule,q,44);
        end
    end
end
r.gap=r.oracle-r.rate;
for s=1:2
    [delta,ci]=confidence_mean(r.gap(:,1,s)-r.gap(:,2,s));
    fprintf('Placement at %g dB: edge-minus-uniform paired loss %.3f +/- %.3f Mbit/s (95%% CI).\n',r.input_dB(s),delta,ci);
end
save_result(out,'placement',r);
end
