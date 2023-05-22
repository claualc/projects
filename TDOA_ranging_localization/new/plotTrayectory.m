function [] = plotTrayectory(parameters,AP, trayectory)
    plot( AP(:,1) , AP(:,2) , '^','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]), hold on
    plot( trayectory(:,1) , trayectory(:,2) , '-o','MarkerIndices',1:20:parameters.simulationTime)
    legend('UE true','KF est.')
    xlabel('[m]'), ylabel('[m]');
    xlim([parameters.xmin parameters.xmax])
    ylim([parameters.ymin parameters.ymax])
    axis equal
    grid on
end