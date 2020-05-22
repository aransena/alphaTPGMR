function r = generate_trajectory(model, r) 
    for n = 1:length(r)
        MuTmp = zeros(size(model.MuGMR));
        SigmaTmp = zeros(size(model.SigmaGMR));
        for m=1:model.nbFrames
            MuTmp(:,:,m) = r(n).p(m).A(2:end,2:end) * model.MuGMR(:,:,m) + repmat(r(n).p(m).b(2:end),1,model.nbData);
            for t=1:model.nbData
                SigmaTmp(:,:,t,m) = r(n).p(m).A(2:end,2:end) * model.SigmaGMR(:,:,t,m) * r(n).p(m).A(2:end,2:end)';
            end
        end
        %Product of Gaussians (fusion of information from the different coordinate systems)
        for t=1:model.nbData
            SigmaP = zeros(size(model.SigmaGMR,1));
            MuP = zeros(size(model.MuGMR,1), 1);
            for m=1:model.nbFrames
                SigmaP = SigmaP + inv(SigmaTmp(:,:,t,m));
                MuP = MuP + SigmaTmp(:,:,t,m) \ (MuTmp(:,t,m));
            end
            r(n).Sigma(:,:,t) = inv(SigmaP);
            r(n).Data(1,t) = model.dt*t;
            r(n).Data(2:1+length(MuP),t) = r(n).Sigma(:,:,t) * MuP;
        end
    end
end