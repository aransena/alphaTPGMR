%% Demo of frame relevance weighted task parameterised learning
% Demo of alphaTPGMR method, compared against TP-GMR model.
% Given a set of demonstrations, a reproduction of the original demos is
% generated using alphaTPGMR and then TPGMR. Trajectories are then generated
% with both methods for a set of randomly generated task parameters to test
% generalisation capabilities.
%
%
% Please see main paper for full details:
% @inproceedings{Sena2019ImprovingGeneration,
%     title = {Improving Task-Parameterised Movement Learning Generalisation with Frame-Weighted Trajectory Generation},
%     booktitle = {IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)},
%     year = {2019},
%     author = {Sena, Aran and Michael, Brendan and Howard, Matthew},
%     url = {https://ieeexplore.ieee.org/document/8967688},
%     arxivId = {1903.01240}
% }
%
% author: Aran Sena
% contact: aran.sena@kcl.ac.uk
% 
% Referenced work + code detailed below...
%

%% MATLAB Dependencies
% 
% Statistics and Machine Learning Toolbox % <- Used during frame weights initialisation
% Robotics System Toolbox % <- Used in handling of orientations and transforms

% If any of the dependencies presents a problem for you running the code,
% please contact me and I can investigate if it can be removed.

%% Prior code and related work:
% @article{Calinon16JIST,
%   author="Calinon, S.",
%   title="A Tutorial on Task-Parameterized Movement Learning and Retrieval",
%   journal="Intelligent Service Robotics",
%		publisher="Springer Berlin Heidelberg",
%		doi="10.1007/s11370-015-0187-9",
%		year="2016",
%		volume="9",
%		number="1",
%		pages="1--29"
% }

% @inproceedings{Alizadeh2014,
%     title = {{Learning from demonstrations with partially observable task parameters}},
%     year = {2014},
%     booktitle = {IEEE International Conference on Robotics and Automation (ICRA)},
%     author = {Alizadeh, Tohid and Calinon, Sylvain and Caldwell, Darwin G.},
%     url = {http://ieeexplore.ieee.org/articleDetails.jsp?arnumber=6907335},
%     isbn = {978-1-4799-3685-4},
%     doi = {10.1109/ICRA.2014.6907335},
%     keywords = {Covariance matrices, Data models, Gaussian mixture model, Gaussian mixture model framework, Gaussian processes, Robot kinematics, Trajectory, candidate frames, control engineering computing, coordinate systems, descriptive features, dust sweeping task, learning systems, mixture models, partially observable task parameters, reference systems, robot learning, robot programming, robot workspace, sensor unavailability, variable number, visual occlusion},
%     language = {English}
% }

% @inproceedings{Huang2018GeneralizedLearning,
%     title = {{Generalized Task-Parameterized Skill Learning}},
%     year = {2018},
%     booktitle = {IEEE International Conference on Robotics and Automation (ICRA)},
%     author = {Huang, Yanlong and Silverio, Joao and Rozo, Leonel and Caldwell, Darwin G.},
%     url = {https://ieeexplore.ieee.org/document/8461079/},
%     isbn = {978-1-5386-3081-5},
%     doi = {10.1109/ICRA.2018.8461079}
% }

% Copyright notice from pbdlib >> 
% Copyright (c) 2015 Idiap Research Institute, http://idiap.ch/
% Written by Sylvain Calinon, http://calinon.ch/
% 
% This file is part of PbDlib, http://www.idiap.ch/software/pbdlib/
% 
% PbDlib is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
% 
% You should have received a copy of the GNU General Public License
% along with PbDlib. If not, see <http://www.gnu.org/licenses/>.

%% Start of Code
addpath('./data');
addpath('./fn');

%% Model Parameters
model.nbStates = 3; %Number of Gaussians in the GMM
model.nbFrames = 2; %Number of candidate frames of reference
model.nbVar = 3; %Dimension of the datapoints in the dataset (here: t,x1,x2)
model.dt = 1E-2; %Time step duration
model.params_diagRegFact = 1e-8; %Optional regularization term
model.nbData = 200; %Number of datapoints in a trajectory

%% Load data
load('data/Data02.mat');
model.nbSamples = length(s);

%% Local Data Transformation
Data = zeros(model.nbVar, model.nbFrames, model.nbSamples*model.nbData);
for i=1:model.nbSamples
    for j=1:model.nbFrames
        Data(:,j,(i-1)*model.nbData+1:i*model.nbData) = s(i).p(j).A \ (s(i).Data0 - repmat(s(i).p(j).b, 1, model.nbData));
    end
end
model.Data = Data;

% Data grouping for convenience during weightings calculation
model.Data_groups = reshape(model.Data, [model.nbVar,model.nbFrames,model.nbData,model.nbSamples]);

%% TP-GMM learning
fprintf('Parameters estimation of TP-GMM with EM...');
model = init_tensorGMM_timeBased(Data, model); 
model = EM_tensorGMM(Data, model);

%Precomputation of covariance inverses
for j=1:model.nbFrames 
    for i=1:model.nbStates
        model.invSigma(:,:,j,i) = inv(model.Sigma(:,:,j,i));
    end
end

%% Generate GMR
model = generate_gmr(model);


%% Calculate Frame Weights
model = init_gaussian_weights(model);
model = optimize_frame_weights(model, s); 


%% Trajectory Generation
% Reproductions of original demonstrations
repo = s; % <- Assignment to setup the struct
% Using frame weightings
repo_w = generate_trajectory_weighted(model, repo);
% Without frame weightings (standard TP-GMR)
repo_uw = generate_trajectory(model, repo);

% Generalised trajectories - random positions + orientations
gen = s; % <- Assignment to setup the struct
for i = 1:model.nbSamples
%     for j = 1:model.nbFrames  % <- Use if changing both frames
        j = 2;  % <- Use if just changing one frame
        % Random position
        gen(i).p(1,j).b = [0, randi([-2, 2]), randi([-2, 2])]';
        % Random orientation
        gen(i).p(1,j).A = tform2rotm(rotm2tform(gen(i).p(1,j).A) * eul2tform([0, 0, deg2rad(randi([0, 360]))]));
%     end
end
gen_w = generate_trajectory_weighted(model, gen);   
gen_uw = generate_trajectory(model, gen);   

%% Plotting
figure('position',[10,10,1400,500]); hold on;

% Original Demos
subplot(1,3,1); hold on;
plot_alpha = 0.8;
scatter_s(s,'b', plot_alpha)
frame_size = 0.1;
plot_2Dframe(s, frame_size);
axis equal
xlim([-1.1 0.6])
ylim([-1 1])

% Demo reproductions - TPGMR blue, alphatTPGMR red
subplot(1,3,2); hold on;
plot_alpha = 0.3;
scatter_s(repo_uw, 'b', plot_alpha)
plot_alpha = 0.8;
scatter_s(repo_w, 'r', plot_alpha)
plot_2Dframe(repo_uw, frame_size);
axis equal
xlim([-1.1 0.6])
ylim([-1 1])

% Generalised reproductions - TPGMR blue, alphatTPGMR red
subplot(1,3,3); hold on;
plot_alpha = 0.3;
scatter_s(gen_uw, 'b', plot_alpha)
plot_alpha = 0.8;
scatter_s(gen_w, 'r', plot_alpha)
frame_size = 0.2;
plot_2Dframe(gen_uw, frame_size);
axis auto
axis equal