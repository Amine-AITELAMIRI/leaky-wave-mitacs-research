function test_physics()
p=parameters(); b=benchmarks(p);
assert(p.M==16 && abs(p.L-.495)<1e-14);
theta=natural_angle(p.f,p); [f,valid]=angle_frequency(theta,p);
assert(all(valid) && max(abs(f-p.f))<1e-5);
[~,valid]=angle_frequency([0 89 90],p); assert(~any(valid));
failed=false; try; natural_angle(p.fc-1,p); catch; failed=true; end
assert(failed);
[H,dH]=port_response(p.f,[-53 -10 0 31 57],p);
step=1e-5;
numeric=(port_response(p.f,[-53 -10 0 31 57]+step*180/pi,p)- ...
    port_response(p.f,[-53 -10 0 31 57]-step*180/pi,p))/(2*step);
assert(norm(numeric(:)-dH(:))/norm(dH(:))<1e-7);
positive=port_response(p.f,theta,p); negative=port_response(p.f,-theta,p);
for k=1:p.K
    assert(abs(abs(positive(2,k,k))^2-b.matched_gain)<1e-10);
    assert(abs(abs(negative(1,k,k))^2-b.matched_gain)<1e-10);
end
assert(abs(b.extracted_power-(-expm1(-2*p.alpha*p.M*p.d)))<1e-13);
assert(abs(b.extracted_power-(-expm1(-2*p.alpha*p.L)))>1e-3);
assert(max(abs(H(:)).^2)<=b.matched_gain+1e-9);
known=angle_information(H,dH,'known');
common=angle_information(H,dH,'common');
per_tone=angle_information(H,dH,'per_tone');
assert(all(known>=common-1e-9) && all(common>=per_tone-1e-9));
a=reshape(H(1,:,:),[],1); da=reshape(dH(1,:,:),[],1);
zero=abs(da(1))^2-abs(conj(a(1))*da(1))^2/abs(a(1))^2;
assert(abs(zero)<1e-8);
scan_grid=linspace(-90,90,1501); scan=port_response(p.f,scan_grid,p)/sqrt(p.K);
truth=[-43 17 38]; Y=port_response(p.f,truth,p)/sqrt(p.K);
phase=exp(1j*reshape(1:p.K,1,p.K,1));
hat=pilot_scan(scan,Y.*phase,scan_grid,'per_tone');
assert(max(abs(hat-truth))<.2);
fprintf('PASS physics: mapping, feed peaks, radians derivative, power, nuisance FIM, noiseless ML.\n');
end
