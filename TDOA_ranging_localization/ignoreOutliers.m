function [array] = ignoreOutliers(array,tag)

    % Interpolate values ignoring outliers
    array(isnan(array)) = 0;
    max_v_r = [.3 .2 .2 .2];
    max_v = max_v_r(tag);
    for i = 1:length(array)
        if length(array) >= i+1
            init = array(i);
            final = array(i+1);

            diff = (final-init);

            if abs(diff) > max_v
                if diff > 0
                    array(i+1) = init + max_v/2;
                else
                    array(i+1) = init - max_v/2;
                end
            end
            
        end
    end
end