function [total,user_rate] = evaluate_schedule(H,schedule,p,isolation)
% Equal active-band power is the policy; stored powers document final schedules.
K=size(H,2); N=size(H,3); active=find(schedule.users>0);
user_rate=zeros(1,N);
if isempty(active); total=0; return; end
assert(numel(unique(schedule.users(active)))==numel(active));
assert(all(abs(sum(abs(schedule.weights(:,active)).^2,1)-1)<1e-10));
power=p.P/numel(active); received=zeros(K,N);
for b=active
    received(b,:)=power*abs(schedule.weights(:,b).'*reshape(H(:,b,:),2,N)).^2;
end
rho=10^(-isolation/10);
for b=active
    u=schedule.users(b);
    interference=sum(received(active(active~=b),u));
    user_rate(u)=p.B/K*log2(1+received(b,u)/(p.noise/K+rho*interference))/1e6;
end
total=sum(user_rate);
end
