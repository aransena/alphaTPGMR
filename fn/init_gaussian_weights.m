function model = init_gaussian_weights(model)
    for m=1:model.nbFrames
        for t = 1:model.nbData
            if model.nbVar == 3
                a = squeeze(model.Data_groups(2:3,m,t,:))';
            else
                d = squeeze(model.Data_groups(2:end,m,t,:));
                a = d';
            end
                model.wGM{t,m} = fitgmdist(a,1,'RegularizationValue', 1e-2);
        end
    end
end