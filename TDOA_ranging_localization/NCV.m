function [F,R,Q,UE_init,UE_init_COV,x_hat,P_hat] = NCV(parameters)
    %% MOTION MODEL
    %initialization
    UE_init = [0.1,0.1,0,0];
    UE_init_COV = diag([100^2,100^2,100^2,100^2]); %must be as large as possible to for not bias the model
    x_hat = NaN( parameters.simulationTime , 4);
    P_hat = NaN( 4 , 4 , parameters.simulationTime );

    %parameters
    T= parameters.samplingTime;
    I2 = eye(2); %diag 1 2x2
    L = [(T^2)/2 .*I2; T.*I2];
    Q = parameters.sigma_driving*L*L';

    %% PREDICTION MODEL
    F = [I2  T.*I2 ; 0.*I2 I2];
    R = buildCovarianceMatrix( parameters );
end