function rates = configuration_rates(H,p,isolation,catalog)
% Fixed transmit ports give a rate matrix independent of the chosen users.
K=size(H,2); N=size(H,3);
left=reshape(abs(H(1,:,:)).^2,1,K,N);
right=reshape(abs(H(2,:,:)).^2,1,K,N);
gain=(catalog.state==1).*left+(catalog.state==2).*right;
signal=(p.P./catalog.count).*gain;
interference=max(sum(signal,2)-signal,0);
rates=p.B/K*log2(1+signal./(p.noise/K+10^(-isolation/10)*interference))/1e6;
end
