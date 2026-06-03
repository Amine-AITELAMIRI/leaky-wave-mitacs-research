function [f,reachable] = angle_frequency(theta,p)
assert(all(abs(theta)<=90),'Angles must be broadside referenced.');
f = p.fc./cosd(theta);
reachable = isfinite(f) & f>=p.f_min & f<=p.f_max;
end
