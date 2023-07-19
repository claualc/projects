function [] = plotSigmaTests(parameters, sigma_values, paths,AP, fig_title,TYPE)
    figure(),hold on;
    plot(AP(:, 1), AP(:, 2), '^', 'MarkerSize', 10, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', [1 .6 .6],'DisplayName', "AP loc");
    
    for sigId =1:length(sigma_values)
            sigma = sigma_values(sigId);
            path = paths{sigId};
            error = sqrt(sum([path(length(path))-path(length(path)-1)].^2,2));
            name ="";
            switch TYPE
                case "TDOA"
                    name =sprintf('SigmaTDOA %.1f Error %.4f', sigma,error);
                case "Q"
                    name =sprintf('SigmaQ %.1f Error %.4f', sigma,error);
                case "sigmaDriving"
                    name =sprintf('SigmaDriving %.5f Error %.4f', sigma,error);
            end
            plot(path(:, 1), path(:, 2), '-o', 'MarkerIndices', 1:20:parameters.simulationTime, 'DisplayName', name);
    end
    xlabel('[m]'), ylabel('[m]');
    xlim([parameters.xmin parameters.xmax]);
    ylim([parameters.ymin parameters.ymax]);
    axis equal;
    grid on;
    legend('show');
    title(fig_title);
    hold off;
end