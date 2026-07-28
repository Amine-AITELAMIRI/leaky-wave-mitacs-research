function eta = angle_information(H,dH,mode)
% Fisher information is 2*eta/noise for one snapshot, per radian squared.
N=size(H,3); J=size(H,2); eta=zeros(1,N);
for u=1:N
    a=reshape(H(:,:,u),[],1); da=reshape(dH(:,:,u),[],1);
    if strcmp(mode,'known')
        eta(u)=real(da'*da);
    elseif strcmp(mode,'common')
        eta(u)=real(da'*da)-abs(a'*da)^2/max(real(a'*a),realmin);
    else
        for k=1:J
            a=H(:,k,u); da=dH(:,k,u);
            eta(u)=eta(u)+real(da'*da)-abs(a'*da)^2/max(real(a'*a),realmin);
        end
    end
end
eta=max(eta,0);
end
