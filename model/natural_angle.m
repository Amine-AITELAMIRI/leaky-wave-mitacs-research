function theta = natural_angle(f,p)
assert(all(f>=p.fc),'Frequency is below cutoff.');
theta = asind(sqrt(1-(p.fc./f).^2));
end
