function catalog = port_catalog(K,all_active)
if nargin<2; all_active=false; end
state = zeros(3^K-1,K);
for k=1:K
    state(:,k)=mod(floor((1:3^K-1)'/3^(k-1)),3);
end
count=sum(state>0,2);
if all_active; state=state(count==K,:); count=count(count==K); end
catalog=struct('state',state,'count',count);
end
