function model = gaussian_frame_weights(model)
    frame_weights = zeros(model.nbData, model.nbFrames);
    for t = 1:model.nbData
        for m=1:model.nbFrames
                frame_weights(t, m) = (norm(model.wGM{t,m}.Sigma)^(model.gamma));
        end
    end
    
    for t = 1:model.nbData
        
        denom = sum(frame_weights(t,:));
        for m= 1:model.nbFrames
            frame_weights(t,m) = frame_weights(t,m)/denom;
        end
        
    end
    model.frame_weights = smoothdata(frame_weights);
end