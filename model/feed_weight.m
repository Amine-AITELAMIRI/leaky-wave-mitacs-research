function w = feed_weight(h,mode)
if mode==1
    w=[1;0];
elseif mode==2
    w=[0;1];
else
    w=conj(h)/max(norm(h),realmin);     % Unit feed power; H.'*w gives coherent gain.
end
end
