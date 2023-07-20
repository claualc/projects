function [x_hat] = EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho,AP,MODEL, tag, show_plots)
    T = parameters.simulationTime;

    if show_plots == true
           figure();
        plot(AP(:, 1), AP(:, 2), '^', 'MarkerSize', 10, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', [1 .6 .6],'DisplayName', "AP loc"), hold on;
        axis equal;
        xlim([parameters.xmin parameters.xmax]);
        ylim([parameters.ymin parameters.ymax]);
        xlabel('[m]'), ylabel('[m]');
        subTitle= sprintf("sigmaTDOA=%.1f sigmaQ=%.1f", parameters.sigmaTDOA,parameters.sigmaQ);
        title(sprintf("Path estimated %s -EFK", MODEL),subTitle);
        name = sprintf("tag %d", tag);
    end

    for time=1:T
        %prediction
        if time == 1
            x_pred =  UE_init';
            P_pred = UE_init_COV;
        else
            x_pred = F * x_hat(time-1,:)';
            P_pred = F * P_hat(:,:,time-1) *F' + Q;
        end
        H = buildJacobianMatrixH(parameters,x_pred(1:2)',AP);
        
        if MODEL == 'NCV'
            H = [H, zeros(parameters.numberOfAP-1,2)];
        end
    
        %update
        G = P_pred * H' * inv( H*P_pred*H' + R);
        x_hat(time,:) = x_pred + G*(rho(time,:)' - measurementModel( parameters , x_pred(1:2)' , AP )' );
        P_hat(:,:,time) = P_pred - G * H * P_pred;

        %plot evolution
        if MODEL == 'NCP'
            if time == 1 && show_plots == true
                plotCovariance( P_pred  , x_pred(1) , x_pred(2)  , 3 , 'Prior');
                plotCovariance( P_hat(:,:,time)  , x_hat(time,1) , x_hat(time,2)  , 3 , 'Update');
                plot( x_hat(time,1) , x_hat(time,2) , 'o','MarkerSize',12, 'MarkerFaceColor','cyan','MarkerEdgeColor','cyan','DisplayName', 'First Move');
            end
        end
        
    end
    if show_plots == true
          plot( x_hat(:,1) , x_hat(:,2) , '-o','MarkerIndices',1:20:parameters.simulationTime, 'DisplayName', name,'Color','blue'); 
          legend('show');
          hold off;
    end
end