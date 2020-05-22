function [model] = optimize_frame_weights(model,s)
    disp('Finding frame weights...')
    
    %% Test set
    for i = 1:length(s)
        test_set(i).p = s(i).p;
    end
    
    %% Optimization parameters
    options = optimset('FunValCheck','on');
    k = 0;
    min_loss = NaN;
    for i = -125:5:1
        try
            [gamma min_loss] = fminbnd(@(x)objective_fn(x,model,s,test_set),i,0, options);
            if ~isnan(min_loss)
                break
            end
        catch
        end           
    end
    
    model.gamma = gamma;
    model = gaussian_frame_weights(model);
    
    disp(strcat(['Gamma: ', num2str(model.gamma), ', Loss: ', num2str(min_loss)]));
end