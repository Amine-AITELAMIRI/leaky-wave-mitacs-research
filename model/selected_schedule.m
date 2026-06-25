function [total,schedule] = selected_schedule(H,p,isolation,catalog)
if nargin<4; catalog=port_catalog(size(H,2)); end
K=size(H,2); N=size(H,3); assert(N>0);
rates=configuration_rates(H,p,isolation,catalog);
upper=sum(max(rates,[],3),2);
upper(catalog.count>N)=-Inf;
[upper,order]=sort(upper,'descend');
total=-Inf; schedule=struct();
for i=1:numel(order)
    if upper(i)<=total+1e-11; break; end
    row=order(i); active=find(catalog.state(row,:)>0);
    R=reshape(rates(row,active,:),numel(active),N);
    [value,pairs]=solve_assignment(R);
    if value>total
        total=value;
        bands=reshape(active(pairs(:,1)),[],1);
        schedule.users=zeros(1,K); schedule.users(bands)=pairs(:,2);
        schedule.weights=zeros(2,K);
        for b=bands.'
            schedule.weights(catalog.state(row,b),b)=1;
        end
    end
end
schedule.passes=0;
schedule.powers=p.P*(schedule.users>0)/sum(schedule.users>0);
end
