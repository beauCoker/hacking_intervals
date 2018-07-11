function [effect_min, effect_max, ...
    effect_geo_min, effect_geo_max, ...
    flag_min, flag_max, ...
    lambdastar_min, lambda0star_min, ...
    lambdastar_max, lambda0star_max]=f_svm_hacked(V, y, C, theta, xnew, x0)
%% Calculates SVM hacking intervals on new observation
%
%Input (see Parameters):
%   V: Loss constraint features
%   y: Labels {-1,+1}
%   C: Regularization tradeoff
%   theta: Loss constraint
%   xnew: Observation on which to calculate hacking interval
%   x0: Starting point for optimization
%Output:
%   effect_range: hacking interval as [lower_bound upper_bound]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Precalculate:
[n, ~] = size(V);
M = y.*V;
H = M*M';

s_min=1; % s=1 for minimum range, s=-1 for max range
s_max=-1; % s=1 for minimum range, s=-1 for max range

%% Solve Dual
% Use fmincon
dual_obj_min = @(x)f_dual_obj(x, M, H, xnew, theta, s_min); % Returns gradient
dual_obj_max = @(x)f_dual_obj(x, M, H, xnew, theta, s_max); % Returns gradient

% alpha_i - beta*C <= 0
A = [eye(n) -C*ones(n,1)];
b = zeros(n,1);

% \sum alpha_i y_i = s
Aeq = [y' 0];
beq_min = s_min;
beq_max = s_max; 

% All variables non-negative
lb = zeros(n+1,1); 
ub = [];

nonlcon = [];

options = optimoptions('fmincon',...
    'Display','off',...
    'SpecifyObjectiveGradient',true,...
    'Algorithm','interior-point'); %active-set is slow, trust-region-reflective doesn't work for this problem
    %'MaxFunctionEvaluations',2000,...
    
[x_min, ~, flag_min, output_min] = fmincon(dual_obj_min,x0,A,b,Aeq,beq_min,lb,ub,nonlcon,options);

[x_max, ~, flag_max, output_max] = fmincon(dual_obj_max,x0,A,b,Aeq,beq_max,lb,ub,nonlcon,options);

%% Back out primal solution (min effect)
beta_min = x_min(end);
alpha_min = x_min(1:end-1);

% lambda
lambdastar_min = 1/beta_min * (V'*(alpha_min.*y) - s_min*xnew);

% lambda0
r_min=beta_min*C-alpha_min; % Dual variables for slack variables
[~,i_sv1_min] = min(abs(alpha_min-r_min)); % Support vector with margin 1
lambda0star_min = y(i_sv1_min) - V(i_sv1_min,:) * lambdastar_min;

% Old way:
%idx_min = find(r_min > .001 & alpha_min > .001); % Support vectors with margin = 1, I think
%lambda0star_all_min = y(idx_min) - V(idx_min,:) * lambdastar_min;
%lambda0star_min = max(lambda0star_all_min);


%% Back out primal solution (max effect)
beta_max = x_max(end);
alpha_max = x_max(1:end-1);

% lambda
lambdastar_max = 1/beta_max * (V'*(alpha_max.*y) - s_max*xnew);

% lambda0
r_max=beta_max*C-alpha_max; % Dual variables for slack variables
[~,i_sv1_max] = min(abs(alpha_max-r_max)); % Support vector with margin 1
lambda0star_max = y(i_sv1_max) - V(i_sv1_max,:) * lambdastar_max;

% Old way:
%idx_max = find(r_max > .001 & alpha_max > .001); % Support vectors with margin = 1, I think
%lambda0star_all_max = y(idx_max) - V(idx_max,:) * lambdastar_max;
%lambda0star_max = max(lambda0star_all_max);


%% Calculate effects

effect_min = lambdastar_min'*xnew + lambda0star_min;
effect_max = lambdastar_max'*xnew + lambda0star_max;

effect_geo_min = effect_min/norm(lambdastar_min);
effect_geo_max = effect_max/norm(lambdastar_max);

end
