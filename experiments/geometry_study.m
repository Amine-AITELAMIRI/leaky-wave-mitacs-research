function result = geometry_study(p,out)
f=linspace(p.f_min,p.f_max,300);
theta=natural_angle(f,p);
linear=interp1(f([1 end]),theta([1 end]),f);
[error,index]=max(abs(linear-theta));
scan=linspace(-90,90,4001);
response=port_response(p.f,scan,p);
gain=reshape(max(abs(response).^2,[],1),p.K,[]);
covered=max(gain,[],1)>=max(gain,[],'all')*10^(-3/10);
edges=diff([false covered false]); first=find(edges==1); last=find(edges==-1)-1;
intervals=[scan(first).' scan(last).'];
users=[-55 -40 -20 -5 5 20 40 55];
H=port_response(p.f,users,p); selected=reshape(max(abs(H).^2,[],1),p.K,[]);
rate=p.B*log2(1+p.P*selected/p.noise)/1e6;
b=benchmarks(p);
natural=natural_angle(p.f,p); validation=zeros(p.K,4);
for k=1:p.K
    a=port_response(p.f(k),natural(k),p);
    validation(k,:)=[p.f(k)/1e9,natural(k),abs(a(2))^2,p.B*log2(1+p.P*abs(a(2))^2/p.noise)/1e6];
end
test_angles=[36 9 54;33 38 54];
% The old 10-degree beam needs an out-of-band tone; use the lower band edge.
f3=max(p.f_min,p.fc./cosd([10 35 55])); assignment=zeros(2,2);
for j=1:2
    h=port_response(f3,test_angles(j,:),p);
    [assignment(j,1),s]=selected_schedule(h,p,Inf);
    [assignment(j,2),~]=coherent_schedule(h,p,Inf,s);
end
alpha=logspace(-2,1.5,100); peak=zeros(size(alpha));
for i=1:numel(alpha)
    q=p; q.alpha=alpha(i); q.C=sqrt(-expm1(-2*q.alpha*q.d))*ones(1,q.M);
    reference=benchmarks(q); peak(i)=reference.matched_gain;
end
cluster=port_response(p.f,[9 31 35 56 59],p);
cluster_rate=zeros(3,2);
for i=1:3
    iso=[0 44 Inf]; [r,s]=selected_schedule(cluster,p,iso(i));
    cluster_rate(i,:)=[r,sum(s.users>0)];
end
result=struct('p',p,'frequency',f,'theta',theta,'linear',linear,'mapping_error',error, ...
    'error_angle',theta(index),'scan',scan,'gain',gain,'covered_intervals',intervals, ...
    'users',users,'rate',rate,'benchmarks',b,'natural_validation',validation, ...
    'test_angles',test_angles,'assignment',assignment,'alpha',alpha,'peak_gain',peak, ...
    'cluster_rate_active',cluster_rate);
result.assignment_frequencies=f3;
result.beam_separation=diff(natural);
swept=reshape(max(abs(port_response(linspace(p.f_min,p.f_max,200),scan,p)).^2,[],1),200,[]);
mask=max(swept,[],1)>=b.matched_gain*10^(-3/10);
edges=diff([false mask false]); starts=find(edges==1); stops=find(edges==-1)-1;
result.swept_halfpower_intervals=[scan(starts).' scan(stops).'];
curve=gain(3,:); [~,peak_index]=max(curve);
mins=find(diff(curve(1:end-1))<0 & diff(curve(2:end))>0)+1;
left=mins(find(mins<peak_index,1,'last')); right=mins(find(mins>peak_index,1));
result.half_minima_width=(scan(right)-scan(left))/2;
fprintf('Mapping error %.6f deg; mapped span %.6f deg; matched TDMA %.6f Mbps.\n', ...
    error,2*(theta(end)-theta(1)),b.matched_Mbps);
disp(array2table(validation,'VariableNames',{'GHz','NaturalDeg','RightGain','FullBandMbps'}));
disp(array2table(cluster_rate,'VariableNames',{'ClusterMbps','ActiveBands'}));
save_result(out,'geometry',result);
end
