function [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCP(parameters)
    %% MOTION MODEL    
    %initialization
    UE_init = [5.57/2,3.35/2];
    UE_init_COV = diag([2^2,2^2]); %must be as large as possible to for not bias the model
    x_hat = NaN( parameters.simulationTime , 2);
    P_hat = NaN( 2 , 2 , parameters.simulationTime );
    %parameters
    Q = diag([ parameters.sigmaQ , parameters.sigmaQ]);

    %% PREDICTION MODEL
    F = [1 , 0 ; 0  1];
    R = buildCovarianceMatrix( parameters );
end