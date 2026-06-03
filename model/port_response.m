function [H,dH_drad] = port_response(f,theta_deg,p)
% H is port x frequency x angle; the derivative is per radian.
assert(all(f>=p.fc),'Frequency is below cutoff.');
assert(all(abs(theta_deg)<=90),'Use broadside-referenced angles in [-90,90].');
H = complex(zeros(2,numel(f),numel(theta_deg)));
dH_drad = H;
for k=1:numel(f)
    k0 = 2*pi*f(k)/p.c0;
    beta = k0*sqrt(1-(p.fc/f(k))^2);
    space = exp(-1j*k0*p.z(:)*sind(theta_deg(:).'));
    left = (p.C.*exp(-p.alpha*p.z).*exp(-1j*beta*p.z)).';
    right = (p.C.*exp(-p.alpha*(p.L-p.z)).*exp(-1j*beta*(p.L-p.z))).';
    fields = [left.'*space; right.'*space];
    derivative = -1j*k0*([(left.*p.z(:)).';(right.*p.z(:)).']*space).*cosd(theta_deg(:).');
    H(:,k,:) = reshape(fields,2,1,[]);
    dH_drad(:,k,:) = reshape(derivative,2,1,[]);
end
end
