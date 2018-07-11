function out=f_recid(...
    C,...
    theta_factor,...
    file_in)

%% Calculates hacking intervals by calling f_svm_hacked
% Requires data from setup.m. Hacking intervals are calculated for each
% observation in xnew. Writes results to ['svm_output_' name_group '.csv'].
%
%Input (see Parameters):
%   C: Regularization tradeoff parameter for SVM
%   theta_factor: Factor by which to multiply minimum loss for hacking loss
%       constraint.
%   name_group: Name of group (e.g., race) on which to group hacking
%   intervals (used for data input and output).
%Output:
%   out: table with the idenficiation variables and hacking intervals (LB,
%   UB and Diff=UB-LB) for each observation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data and allocate space

load(file_in)

n_group = length(u_group);

effect_group = cell(1, n_group);

[n, ~] = size(V);

%% SVM
[lambdastar_svm, lambda0star_svm, alpha_svm, primal_svm]=f_svm(V, y, C);

% Compare to built-in method
mdl = fitcsvm(V,y); % Uses SMO by default

mdl.predict(V); % Compare the ypred

mdl.Beta; % Compare to lambdastar_svm
mdl.Bias; % Compare to lambda0star_svm

Alpha = zeros(n,1);
Alpha(mdl.IsSupportVector) = mdl.Alpha;

compare = [lambdastar_svm mdl.Beta] % These should be similar

%% Hacking intervals

theta = theta_factor*primal_svm;
x0 = [alpha_svm; 0]; % Initial guess for fmincon

% Loop through groups
for k = 1:n_group
    fprintf('Starting group %d of %d...\n',k,n_group)
    temp = nan(size(xnew{k},1),6);
    
    % Calculate hacking intervals on observations in group
    for i = 1:size(xnew{k},1)
        if mod(i,25)==0
            fprintf('Starting observation %d of %d...\n',i,size(xnew{k},1))
        end
        
        [temp(i,1),temp(i,2),temp(i,3),temp(i,4),temp(i,5),temp(i,6)] = f_svm_hacked(V, y, C, theta, xnew{k}(i,1:end-1)', x0);
    end
    effect_group{k} = temp;
end

%% Assemble table

out = [vertcat(xnew_id{:}) array2table(vertcat(effect_group{:}),'VariableNames',{'LB','UB','LB_geo','UB_geo','flag_min','flag_max'})];

