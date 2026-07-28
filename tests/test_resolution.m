function test_resolution()
p=parameters(); rng(7042);
theta=rand(1,30)*120-60;
H=port_response(p.f,theta,p)/sqrt(p.K);
Y=H+.1*(randn(size(H))+1j*randn(size(H)))/sqrt(2);
coarse=linspace(-90,90,1501); fine=linspace(-90,90,3001);
a=pilot_scan(port_response(p.f,coarse,p)/sqrt(p.K),Y,coarse,'per_tone');
b=pilot_scan(port_response(p.f,fine,p)/sqrt(p.K),Y,fine,'per_tone');
assert(max(abs(a-b))<.1,'Pilot grid needs refinement.');
catalog=port_catalog(p.K,true);
R=configuration_rates(port_response(p.f,theta,p),p,44,catalog);
[value,row,pairs]=weighted_configuration(R,1:30);
truth=-Inf;
for j=1:size(R,1)
    truth=max(truth,solve_assignment(reshape(R(j,:,:),p.K,30).*(1:30)));
end
assert(abs(value-truth)<1e-8);
assert(numel(unique(pairs(:,2)))==p.K && row>0);
fprintf('PASS resolution and weighted scheduling: grid change %.5f deg; all 64 states checked.\n',max(abs(a-b)));
end
