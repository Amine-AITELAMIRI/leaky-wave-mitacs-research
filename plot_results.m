function plot_results()
root=fileparts(mfilename('fullpath')); addpath(fullfile(root,'model'));
folder=fullfile(root,'figures'); if ~exist(folder,'dir'); mkdir(folder); end
set(groot,'defaultFigureVisible','off','defaultFigureColor','w', ...
    'defaultAxesFontSize',11,'defaultLineLineWidth',1.6,'defaultTextInterpreter','tex');
g=read_result(root,'geometry'); h=read_result(root,'headline');
c=read_result(root,'convergence'); f=read_result(root,'fairness');
l=read_result(root,'localization'); v=read_result(root,'placement');
fig=figure('Position',[50 50 1000 700]); tiledlayout(2,1,'TileSpacing','compact');
nexttile;
plot(g.frequency/1e9,g.theta,'DisplayName','Right port'); hold on;
plot(g.frequency/1e9,-g.theta,'DisplayName','Left port');
plot(g.frequency/1e9,g.linear,'--','DisplayName','Endpoint-linear reference');
xlabel('Frequency (GHz)'); ylabel('Natural angle (deg)'); title('Dispersion and mapped beam directions');
grid on; legend('Location','eastoutside');
nexttile;
plot(g.scan,10*log10(max(g.gain,[],1)/g.benchmarks.matched_gain),'DisplayName','Best of six bands and either port');
yline(-3,'--','DisplayName','-3 dB threshold'); grid on; ylim([-30 2]); xlim([-90 90]);
xlabel('Angle (deg)'); ylabel('Gain / coherent single-port peak (dB)');
title('Discrete-band half-power coverage is not the mapped angle range'); legend('Location','south');
finish(fig,folder,'mapping_coverage');

fig=figure('Position',[50 50 1000 570]); tiledlayout(1,2,'TileSpacing','compact');
nexttile; imagesc(1:numel(g.users),g.p.f/1e9,g.rate); axis xy; colorbar;
xticks(1:numel(g.users)); xticklabels(compose('%g',g.users));
xlabel('User angle (deg)'); ylabel('Band center (GHz)'); title('Isolated full-band link rate (Mbit/s)');
nexttile; semilogx(g.alpha,g.peak_gain,'DisplayName','Matched-taper peak'); hold on;
xline(g.p.alpha,'--','DisplayName','Selected analytical design point');
grid on; xlabel('Leakage \alpha (Np/m)','Interpreter','tex'); ylabel('Normalized link gain');
title('Uniform coupling linked to leakage'); legend('Location','south');
finish(fig,folder,'capacity_design');

fig=figure('Position',[50 50 1100 740]); tiledlayout(2,2,'TileSpacing','compact');
for q=1:4
    nexttile; hold on;
    for a=1:2
        [mu,ci]=confidence_mean(h.rate(:,:,q,a));
        labels={'Selected port: exact','Coherent feed: heuristic'};
        errorbar(h.N,mu,ci,'-o','DisplayName',labels{a});
    end
    yline(h.reference.matched_Mbps,'--','DisplayName','Matched-taper TDMA');
    grid on; xlabel('Number of users N'); ylabel('Gross sum rate (Mbit/s)');
    if isinf(h.isolation(q)); title('Ideal receiver isolation');
    else; title(sprintf('Receiver rejection: %g dB',h.isolation(q))); end
    ylim([0 290]); if q==4; legend('Location','southeast'); end
end
finish(fig,folder,'headline');

fig=figure('Position',[50 50 1000 540]); tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for q=1:3
    [mu,ci]=confidence_mean(h.sensitivity(:,:,q));
    labels={'20 dB rejection','44 dB rejection','Ideal isolation'};
    errorbar(h.snr,mu,ci,'-o','DisplayName',labels{q});
end
grid on; xlabel('Matched-taper full-band operating SNR (dB)'); ylabel('TDMA fraction (%)');
title('N=30; fixed occupied bandwidth and power'); legend('Location','southwest');
nexttile; hold on;
for q=1:4
    plot(h.N,mean(h.active(:,:,q,1),1),'-o','DisplayName',sprintf('%g dB',h.isolation(q)));
end
grid on; xlabel('Number of users N'); ylabel('Mean active bands');
title('Exact selected-port decisions'); ylim([0 6.3]); legend('Location','southeast');
finish(fig,folder,'sensitivity');

fig=figure('Position',[50 50 1050 560]); tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for q=1:2
    [mu,ci]=confidence_mean(c.rate(:,:,q));
    errorbar(c.N,mu,ci,'-o','DisplayName',sprintf('%g dB fixed policy',c.isolation(q)));
    yline(c.limit(q),'--','HandleVisibility','off');
end
set(gca,'XScale','log'); grid on; xlabel('Number of users N'); ylabel('Gross sum rate (Mbit/s)');
title('Fixed alternating-port policy: 400 nested populations'); legend('Location','southeast');
nexttile; loglog(c.N,mean(c.interior_loss,1),'-o','DisplayName','Interior peak'); hold on;
loglog(c.N,mean(c.boundary_loss,1),'-s','DisplayName','Support boundary');
grid on; xlabel('Number of users N'); ylabel('Mean one-band loss (Mbit/s)');
title('Fixed-policy scaling controls'); legend('Location','southwest');
finish(fig,folder,'convergence');

fig=figure('Position',[50 50 1000 560]); tiledlayout(1,2,'TileSpacing','compact');
nexttile;
average=squeeze(mean(sort(f.average(:,1,:,:),4),1));
plot(sort(average(1,:)),'-o','DisplayName','Opportunistic'); hold on;
plot(sort(average(2,:)),'-s','DisplayName','Proportional fair');
grid on; xlabel('User rank (sorted within each population)'); ylabel('Mean user rate (Mbit/s)');
title('44 dB, 20 populations, 1000 intervals'); legend('Location','best');
nexttile; hold on;
for q=1:2
    [mu,ci]=confidence_mean(sum(f.average(:,q,:,:),4));
    errorbar([1 2]+.05*(q-1),reshape(mu,1,2),reshape(ci,1,2),'o-', ...
        'DisplayName',sprintf('%g dB',f.isolation(q)));
end
xticks([1 2]); xticklabels({'Opportunistic','Proportional fair'}); xlim([.8 2.3]);
grid on; ylabel('Sum rate (Mbit/s)'); title('Same all-active selected-port action set'); legend('Location','best');
finish(fig,folder,'fairness');

fig=figure('Position',[50 50 1050 570]); tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for j=1:3
    [mu,ci]=confidence_mean(100*l.rate(:,j,3,:)./reshape(l.oracle,[],1,1,1));
    labels={'1 pilot tone','3 pilot tones','6 pilot tones'};
    errorbar(l.input_dB,reshape(mu,1,[]),reshape(ci,1,[]),'-o','DisplayName',labels{j});
end
yline(95,'--','HandleVisibility','off'); grid on; ylim([0 105]);
xlabel('Total pilot energy / noise variance (dB)'); ylabel('Perfect-angle oracle retained (%)');
title('Unknown channel per tone; 100 paired populations'); legend('Location','southeast');
nexttile; hold on;
names={'Known channel','Calibrated relative phase','Unknown channel per tone'};
for m=1:3
    [mu,ci]=confidence_mean(100*l.rate(:,3,m,:)./reshape(l.oracle,[],1,1,1));
    errorbar(l.input_dB,reshape(mu,1,[]),reshape(ci,1,[]),'-o','DisplayName',names{m});
end
grid on; ylim([0 105]); xlabel('Total pilot energy / noise variance (dB)');
ylabel('Perfect-angle oracle retained (%)'); title('Six tones; calibration assumptions exposed');
legend('Location','southeast'); finish(fig,folder,'localization_rate');

fig=figure('Position',[50 50 1050 570]); tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for j=1:3
    rmse=sqrt(mean(l.rmse(:,j,3,:).^2,1));
    semilogy(l.input_dB,reshape(rmse,1,[]),'-o','DisplayName',sprintf('ML, %d tones',l.pilot_count(j)));
    bound=sqrt(mean(l.crlb(:,j,3,:).^2,'all'))*10.^(-l.input_dB/20);
    semilogy(l.input_dB,bound,'--','DisplayName',sprintf('Local bound, %d tones',l.pilot_count(j)));
end
set(gca,'YScale','log'); grid on; xlabel('Total pilot energy / noise variance (dB)'); ylabel('Angle error (deg)');
title('Unknown per-tone channel: global error vs local bound'); legend('Location','southwest','FontSize',9);
nexttile; hold on;
for j=1:3
    plot(l.input_dB,100*reshape(mean(l.outlier(:,j,3,:),1),1,[]),'-o','DisplayName',sprintf('%d tones',l.pilot_count(j)));
end
grid on; xlabel('Total pilot energy / noise variance (dB)'); ylabel('Users with |error| > 7.12 deg (%)');
title('Outliers are not a capacity-retention percentage'); legend('Location','northeast');
finish(fig,folder,'localization_error');

fig=figure('Position',[50 50 1050 570]); tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for j=1:3
    offset=10*log10(mean(l.received_gain(:,j,:),'all'));
    plot(l.input_dB,l.input_dB+offset,'-o','DisplayName',sprintf('J = %d',l.pilot_count(j)));
end
grid on; xlabel('Total pilot energy / noise variance (dB)'); ylabel('Mean received per-observation SNR (dB)');
title('Fixed energy: noise is not rescaled by received gain'); legend('Location','northwest');
nexttile; hold on;
gross=reshape(mean(l.rate(:,3,3,:),1),1,[]);
plot(l.input_dB,gross,'-o','DisplayName','Gross achieved rate');
plot(l.input_dB,.97*gross,'-s','DisplayName','Training-adjusted rate');
yline(.97*mean(l.oracle),'--','DisplayName','Same-overhead oracle');
yline(.97*g.benchmarks.matched_Mbps,':','DisplayName','Same-overhead matched TDMA');
grid on; xlabel('Total pilot energy / noise variance (dB)'); ylabel('Sum rate (Mbit/s)');
title('30 training symbols in a 1000-symbol frame'); legend('Location','southoutside','FontSize',9);
finish(fig,folder,'pilot_budget');

fig=figure('Position',[50 50 1000 560]); tiledlayout(1,2,'TileSpacing','compact');
for s=1:2
    nexttile; hold on;
    [mu,ci]=confidence_mean(v.rate(:,:,s));
    errorbar([1 2],mu,ci,'-o','DisplayName','Achieved rate');
    [mu,ci]=confidence_mean(v.oracle);
    errorbar([1 2],mu,ci,'--s','DisplayName','Placement-specific oracle');
    xticks([1 2]); xticklabels({'Edge clusters','Uniform tones'}); xlim([.8 2.2]);
    ylabel('Sum rate (Mbit/s)'); grid on;
    title(sprintf('Pilot energy / noise: %g dB',v.input_dB(s))); legend('Location','best');
end
finish(fig,folder,'tone_placement');
fprintf('Figures regenerated from saved trial results only.\n');
end

function r=read_result(root,name)
data=load(fullfile(root,'results',[name '.mat']),'result'); r=data.result;
end
function finish(fig,folder,name)
axes_list=findall(fig,'Type','axes');
for ax=axes_list.'
    if ~isempty(findobj(ax,'Type','image')); continue; end
    limits=ax.XLim;
    if strcmp(ax.XScale,'log')
        padding=.025*diff(log(limits)); ax.XLim=exp(log(limits)+[-padding padding]);
    else
        padding=.025*diff(limits); ax.XLim=limits+[-padding padding];
    end
end
drawnow; exportgraphics(fig,fullfile(folder,[name '.pdf']),'ContentType','vector','Padding',12);
exportgraphics(fig,fullfile(folder,[name '.png']),'Resolution',300,'Padding',12); close(fig);
end
