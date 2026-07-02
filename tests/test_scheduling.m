function test_scheduling()
rng(137); p=parameters();
for N=2:5
    R=rand(N,N); perm=perms(1:N); best=0;
    for j=1:size(perm,1)
        best=max(best,sum(R(sub2ind([N N],1:N,perm(j,:)))));
    end
    assert(abs(best-solve_assignment(R))<1e-12);
end
for repeat=1:3
    H=port_response(p.f([1 4]),rand(1,4)*120-60,p);
    for isolation=[0 20 44 Inf]
        [r,s]=selected_schedule(H,p,isolation);
        assert(abs(sum(s.powers)-p.P)<1e-12);
        assert(all(s.powers(s.users==0)==0));
        exact=exhaustive_schedule(H,p,isolation,2);
        assert(abs(r-exact)<1e-8);
        assert(abs(r-evaluate_schedule(H,s,p,isolation))<1e-8);
        [coherent,c]=coherent_schedule(H,p,isolation,s);
        assert(abs(sum(c.powers)-p.P)<1e-12);
        restricted=exhaustive_schedule(H,p,isolation,3);
        assert(coherent>=r-1e-8 && coherent<=restricted+1e-8);
        assert(abs(coherent-evaluate_schedule(H,c,p,isolation))<1e-8);
    end
end
H=port_response(p.f,[-50 -35 -20 10 30 55],p);
previous=-Inf;
for iso=[0 20 44 Inf]
    r=selected_schedule(H,p,iso);
    assert(r>=previous-1e-8); previous=r;
end
base=selected_schedule(H(:,:,1:3),p,20);
assert(selected_schedule(H,p,20)>=base-1e-8);
% Changing an interferer's feed must change the victim's rate.
s.users=[1 2 zeros(1,4)]; s.weights=zeros(2,6); s.weights(1,1:2)=1;
[~,r1]=evaluate_schedule(H,s,p,0); s.weights(:,2)=[0;1];
[~,r2]=evaluate_schedule(H,s,p,0); assert(abs(r1(1)-r2(1))>1e-3);
fprintf('PASS scheduling: assignment, exhaustive port states, restricted coherent bound, true interference.\n');
end
