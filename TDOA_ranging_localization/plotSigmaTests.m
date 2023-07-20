function [] = plotSigmaTests(parameters, sigma_values, paths,xhat,AP, fig_title,MODEL)
    figure(),hold on;
    plot(AP(:, 1), AP(:, 2), '^', 'MarkerSize', 10, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', [1 .6 .6],'DisplayName', "AP loc");
    
    for sigId =1:length(sigma_values)
            sigma = sigma_values(sigId);
            path = paths{sigId};
            error = sqrt(sum([path(length(path))-path(length(path)-1)].^2,2));
            name ="";
            switch MODEL
                case 'NCP'
                    name =sprintf('Q %.5f Error %.4f', sigma,error);
                case "NCV"
                    name =sprintf('Sigma %.1e Error %.4f', sigma,error);
            end
            plot(path(:, 1), path(:, 2), '-o', 'MarkerIndices', 1:20:parameters.simulationTime, 'DisplayName', name);
            % plotCovariance( P_pred(:,:,2)  , xhat(1,1) , xhat(1,1)  , 3 , 'Prior');
            % plotCovariance( P_hat(:,:,1)  , xhat(1,1) ,  xhat(1,1), 3 , 'Update');
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