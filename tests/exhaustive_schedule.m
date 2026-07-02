function [best,schedule] = exhaustive_schedule(H,p,isolation,n_modes)
% Tiny test oracle: enumerate user assignments and L/R/MRT feed modes.
K=size(H,2); N=size(H,3); best=-Inf; schedule=struct();
for code=0:(N+1)^K-1
    users=mod(floor(code./(N+1).^(0:K-1)),N+1);
    active=find(users>0);
    if numel(unique(users(active)))~=numel(active); continue; end
    for mode_code=0:n_modes^numel(active)-1
        modes=1+mod(floor(mode_code./n_modes.^(0:numel(active)-1)),n_modes);
        candidate.users=users; candidate.weights=zeros(2,K);
        for j=1:numel(active)
            k=active(j); candidate.weights(:,k)=feed_weight(H(:,k,users(k)),modes(j));
        end
        value=evaluate_schedule(H,candidate,p,isolation);
        if value>best; best=value; schedule=candidate; end
    end
end
end
