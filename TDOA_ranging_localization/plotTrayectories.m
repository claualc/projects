function [] = plotTrayectories(parameters,AP,tags, trayectories,fig_title)
    figure();
    plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]), hold on

    for i=1:length(tags)
        tag = tags(i);
        name = sprintf("tag %d", tag);
        path = trayectories{tag};
        plot( path(:,1) , path(:,2) , '-o','MarkerIndices',1:20:parameters.simulationTime, 'DisplayName', name);     
    end
    xlabel('[m]'), ylabel('[m]');
    xlim([parameters.xmin parameters.xmax]);
    ylim([parameters.ymin parameters.ymax]);
    axis equal;
    grid on;
    legend('show');
    subTitle= sprintf("sigmaTDOA=%.1f sigmaQ=%.1f", parameters.sigmaTDOA,parameters.sigmaQ);
    [t,s] = title(fig_title,subTitle);
    t.FontSize = 16;
    s.FontAngle = 'italic';
    hold off;
end