function localization_study(p,out,smoke)
rng(3042); trials=100; if smoke; trials=2; end
r.config=p; r.seed=3042; r.trials=trials;
r.input_dB=[-25 -20 -15 -10 -5 0 5 10 20];
r.pilot_count=[1 3 6]; r.modes={'known','common','per_tone'};
r.users=rand(trials,30)*120-60; r.grid=linspace(-90,90,1501);
r.isolation=44; r.outlier_threshold_deg=7.12; r.training_fraction=30/p.frame_symbols;
catalog=port_catalog(p.K);
tone_sets={3,[1 3 6],1:6};
dims=[trials 3 3 numel(r.input_dB)];
r.rate=zeros(dims); r.rmse=zeros(dims); r.outlier=zeros(dims);
r.crlb=zeros(trials,3,3,30); r.received_gain=zeros(trials,3,30);
r.theta_hat=zeros([dims 30]); r.oracle=zeros(trials,1);
r.phase=zeros(trials,30); r.delay=zeros(trials,30);
scan=cell(1,3);
for j=1:3; scan{j}=port_response(p.f(tone_sets{j}),r.grid,p)/sqrt(r.pilot_count(j)); end
for t=1:trials
    users=r.users(t,:); Hdata=port_response(p.f,users,p);
    r.oracle(t)=selected_schedule(Hdata,p,r.isolation,catalog);
    r.phase(t,:)=2*pi*rand(1,30); r.delay(t,:)=1e-7*rand(1,30);
    noise=(randn(2,6,30)+1j*randn(2,6,30))/sqrt(2);
    for j=1:3
        tones=tone_sets{j}; J=numel(tones); f=p.f(tones);
        [H,D]=port_response(f,users,p); H=H/sqrt(J); D=D/sqrt(J);
        relative=exp(-1j*2*pi*(f(:)-f(1))*r.delay(t,:));
        phase=exp(1j*r.phase(t,:)); channel=relative.*phase;
        signal=H.*reshape(channel,1,J,30);
        r.received_gain(t,j,:)=sum(abs(H).^2,[1 2])/(2*J);
        for m=1:3
            eta=angle_information(H,D,r.modes{m});
            r.crlb(t,j,m,:)=(180/pi)./sqrt(max(2*eta,realmin));
        end
        for s=1:numel(r.input_dB)
            variance=10^(-r.input_dB(s)/10);
            observed=signal+sqrt(variance)*noise(:,tones,:);
            for m=1:3
                Y=observed;
                if m==1; Y=Y.*reshape(conj(channel),1,J,30); end
                if m==2; Y=Y.*reshape(conj(relative),1,J,30); end
                estimate=pilot_scan(scan{j},Y,r.grid,r.modes{m});
                [~,schedule]=selected_schedule(port_response(p.f,estimate,p),p,r.isolation,catalog);
                r.rate(t,j,m,s)=evaluate_schedule(Hdata,schedule,p,r.isolation);
                error=estimate-users;
                r.rmse(t,j,m,s)=sqrt(mean(error.^2));
                r.outlier(t,j,m,s)=mean(abs(error)>r.outlier_threshold_deg);
                r.theta_hat(t,j,m,s,:)=estimate;
            end
        end
    end
    fprintf('Localization population %d/%d\n',t,trials);
end
assert(all(r.rate<=reshape(r.oracle,[],1,1,1)+1e-8,'all'));
r.net_rate=(1-r.training_fraction)*r.rate;
r.net_oracle=(1-r.training_fraction)*r.oracle;
fprintf('Localization: J=6 unknown per-tone rate retention at 0 / 20 dB: %.3f%% / %.3f%%.\n',100*mean(r.rate(:,3,3,6)./r.oracle),100*mean(r.rate(:,3,3,9)./r.oracle));
save_result(out,'localization',r);
placement_study(p,out,smoke,r.users);
end
