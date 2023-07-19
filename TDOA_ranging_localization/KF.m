function [x_hat] = KF(parameters,F,R,Q,UE_init,UE_init_COV,x_hat,P_hat,rho,AP,MODEL)
    T = parameters.simulationTime;

    R = diag( repmat( parameters.sigmaTDOA.^2 , 1 , parameters.numberOfAP-1 ) );
    H = diag( ones( 1 , 2 ) );
    H = [H; zeros(parameters.numberOfAP-3,2)];
    if MODEL == 'NCV'
        H = diag( ones( 1 , 4 ) );
        H = [H; zeros(parameters.numberOfAP-5,4)];
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
    
        %update
        G = P_pred * H' * inv( H*P_pred*H' + R);
        x_hat(time,:) = x_pred + G*(rho(time,:)' - H*x_pred );
        P_hat(:,:,time) = P_pred - G * H * P_pred;


    end
end