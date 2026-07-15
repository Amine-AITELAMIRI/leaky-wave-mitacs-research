function convergence_study(p,out,smoke)
rng(1042); trials=400; if smoke; trials=4; end
r.config=p; r.seed=1042; r.trials=trials;
r.N=[6 8 12 20 30 50 100 300 1000 3000 10000];
r.isolation=[44 Inf]; r.state=[1 2 1 2 1 2];
catalog.state=r.state; catalog.count=p.K;
grid=linspace(-60,60,24001);
H=port_response(p.f,grid,p);
r.rate=zeros(trials,numel(r.N),2); r.independent=r.rate;
r.limit=zeros(1,2); r.peak=zeros(p.K,2); r.interpolation_error=zeros(1,2);
tables=cell(1,2);
for q=1:2
    tables{q}=reshape(configuration_rates(H,p,r.isolation(q),catalog),p.K,[]);
    for k=1:p.K
        [~,j]=max(tables{q}(k,:)); lo=max(1,j-1); hi=min(numel(grid),j+1);
        [theta,negative]=fminbnd(@(t) -fixed_rate(t,k,p,r.isolation(q),catalog),grid(lo),grid(hi));
        r.peak(k,q)=theta; r.limit(q)=r.limit(q)-negative;
    end
    test=linspace(-59.987,59.983,997);
    exact=reshape(configuration_rates(port_response(p.f,test,p),p,r.isolation(q),catalog),p.K,[]);
    approx=interp1(grid,tables{q}.',test,'pchip').';
    r.interpolation_error(q)=max(abs(exact-approx),[],'all');
    assert(r.interpolation_error(q)<1e-5);
end
% The scaling controls use one fixed beam with an interior or boundary maximum.
theta0=r.peak(1,2); h=1e-3; base=fixed_rate(theta0,1,p,Inf,catalog);
r.curvature=(fixed_rate(theta0+h,1,p,Inf,catalog)-2*base+fixed_rate(theta0-h,1,p,Inf,catalog))/h^2;
r.boundary_support=[theta0+2 theta0+8];
control_grid=linspace(r.boundary_support(1),r.boundary_support(2),1001);
control_rate=arrayfun(@(t) fixed_rate(t,1,p,Inf,catalog),control_grid);
assert(all(diff(control_rate)<0),'Boundary scaling requires a monotone flank.');
r.boundary_limit=control_rate(1); r.interior_limit=base;
r.interior_loss=zeros(trials,numel(r.N)); r.boundary_loss=r.interior_loss;
for t=1:trials
    uniform=rand(1,max(r.N)); users=120*uniform-60;
    for q=1:2
        R=interp1(grid,tables{q}.',users,'pchip').';
        for i=1:numel(r.N)
            sample=R(:,1:r.N(i));
            r.rate(t,i,q)=solve_assignment(sample);
            r.independent(t,i,q)=sum(max(sample,[],2));
        end
        if q==2
            for i=1:numel(r.N)
                [~,idx]=maxk(R(1,1:r.N(i)),min(4,r.N(i)));
                exact=configuration_rates(port_response(p.f,users(idx),p),p,Inf,catalog);
                r.interior_loss(t,i)=max(0,base-max(exact(1,1,:)));
            end
        end
    end
    boundary=r.boundary_support(1)+diff(r.boundary_support)*uniform;
    for i=1:numel(r.N)
        nearest=min(boundary(1:r.N(i)));
        r.boundary_loss(t,i)=max(0,r.boundary_limit-fixed_rate(nearest,1,p,Inf,catalog));
    end
    if mod(t,50)==0; fprintf('Convergence population %d/%d\n',t,trials); end
end
assert(all(diff(r.rate,1,2)>=-1e-8,'all'));
tail=r.N>=100;
r.interior_slope=polyfit(log(r.N(tail)),log(mean(r.interior_loss(:,tail),1)),1);
r.boundary_slope=polyfit(log(r.N(tail)),log(mean(r.boundary_loss(:,tail),1)),1);
fprintf('Fixed-policy limits: 44 dB %.6f, ideal %.6f Mbit/s.\n',r.limit);
fprintf('Interior/boundary fitted exponents: %.3f / %.3f (controlled policies only).\n',r.interior_slope(1),r.boundary_slope(1));
save_result(out,'convergence',r);
end

function rate=fixed_rate(theta,k,p,isolation,catalog)
R=configuration_rates(port_response(p.f,theta,p),p,isolation,catalog);
rate=R(1,k);
end
