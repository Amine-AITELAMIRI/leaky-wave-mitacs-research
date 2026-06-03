function b = benchmarks(p)
a = p.C.*exp(-p.alpha*p.z);
b.matched_gain = sum(a)^2;
b.uniform_gain = p.M;                 % Unit input power, lossless uniform aperture.
b.matched_Mbps = p.B*log2(1+p.P*b.matched_gain/p.noise)/1e6;
b.uniform_Mbps = p.B*log2(1+p.P*b.uniform_gain/p.noise)/1e6;
b.extracted_power = sum(a.^2);
end
