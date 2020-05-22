function model = init_gaussian_weights(model)
    for m=1:model.nbFrames
        for t = 1:model.nbData
                a = squeeze(model.Data_groups(2:3,m,t,:))';
                model.wGM{t,m} = fitgmdist(a,1,'RegularizationValue', 1e-2);
        end
    end
end