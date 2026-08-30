function plot_readme_figures()
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'model'));
out=fullfile(root,'assets');
if ~exist(out,'dir'); mkdir(out); end

h=load(fullfile(root,'results','headline.mat'),'result'); h=h.result;
l=load(fullfile(root,'results','localization.mat'),'result'); l=l.result;

fig=figure('Visible','off','Color','w','Position',[100 100 900 530]);
hold on;
conditions=[20 44]; colors=[0.76 0.34 0.17; 0.04 0.40 0.67];
for i=1:numel(conditions)
    q=find(h.isolation==conditions(i),1);
    values=reshape(h.rate(:,:,q,1),h.trials,[]);
    [mean_rate,margin]=confidence_mean(values);
    errorbar(h.N,mean_rate,margin,'-o','Color',colors(i,:), ...
        'LineWidth',2,'MarkerSize',6,'CapSize',3, ...
        'DisplayName',sprintf('LWA, %d dB assumed rejection',conditions(i)));
end
yline(h.reference.matched_Mbps,'--','Color',[0.25 0.25 0.25], ...
    'LineWidth',1.6,'DisplayName','Matched-taper phased-array TDMA');
grid on; box on; xlim([1 31]); ylim([0 295]);
xticks(h.N); xlabel('Number of users'); ylabel('Mean total throughput (Mbit/s)');
title('Selected-port allocation with known user angles');
legend('Location','southeast'); set(gca,'FontSize',12);
exportgraphics(fig,fullfile(out,'allocation_readme.png'), ...
    'Resolution',220,'Padding',14);
close(fig);

fig=figure('Visible','off','Color','w','Position',[100 100 900 530]);
hold on;
colors=[0.04 0.40 0.67; 0.76 0.34 0.17; 0.15 0.55 0.36];
labels={'1 pilot tone','3 pilot tones','6 pilot tones'};
for j=1:3
    values=reshape(l.rate(:,j,3,:),l.trials,[]);
    retained=100*values./l.oracle;
    [mean_rate,margin]=confidence_mean(retained);
    errorbar(l.input_dB,mean_rate,margin,'-o','Color',colors(j,:), ...
        'LineWidth',2,'MarkerSize',6,'CapSize',3, ...
        'DisplayName',labels{j});
end
yline(100,'--','Color',[0.4 0.4 0.4], ...
    'HandleVisibility','off');
grid on; box on; xlim([-27 22]); ylim([0 105]);
xticks(l.input_dB);
xlabel('Total pilot energy / noise variance (dB)');
ylabel('Rate retained vs known-angle LWA (%)');
title('Allocation after user-angle estimation');
legend('Location','southeast'); set(gca,'FontSize',12);
exportgraphics(fig,fullfile(out,'angle_estimation_readme.png'), ...
    'Resolution',220,'Padding',14);
close(fig);
end
