function [average,halfwidth] = confidence_mean(x,dimension)
if nargin<2; dimension=1; end
n=size(x,dimension); average=mean(x,dimension);
if n<2; halfwidth=NaN(size(average)); return; end
% Student quantile through the beta CDF avoids a Statistics Toolbox dependency.
t=sqrt((n-1)*(1/betaincinv(.05,(n-1)/2,.5)-1));
halfwidth=t*std(x,0,dimension)/sqrt(n);
end
