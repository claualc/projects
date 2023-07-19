function [x_hat] = EKF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho,AP,MODEL)
    T = parameters.simulationTime;
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

    end
end