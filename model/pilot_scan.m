function theta_hat = pilot_scan(scan,Y,theta_grid,mode)
% Responses and data are port x tone x angle/user, with pilot energy included.
J=size(scan,2); n_grid=size(scan,3); N=size(Y,3);
A=reshape(scan,2*J,n_grid); y=reshape(Y,2*J,N);
if strcmp(mode,'known')
    score=2*real(A'*y)-sum(abs(A).^2,1).';
elseif strcmp(mode,'common')
    score=abs(A'*y).^2./max(sum(abs(A).^2,1).',realmin);
else
    score=zeros(n_grid,N);
    for k=1:J
        a=reshape(scan(:,k,:),2,n_grid);
        observed=reshape(Y(:,k,:),2,N);
        score=score+abs(a'*observed).^2./max(sum(abs(a).^2,1).',realmin);
    end
end
[~,idx]=max(score,[],1); theta_hat=theta_grid(idx);
step=theta_grid(2)-theta_grid(1);
for u=1:N
    j=idx(u);
    if j>1 && j<n_grid
        den=score(j-1,u)-2*score(j,u)+score(j+1,u);
        if den<0
            offset=.5*(score(j-1,u)-score(j+1,u))/den;
            theta_hat(u)=theta_hat(u)+step*max(-.5,min(.5,offset));
        end
    end
end
end
