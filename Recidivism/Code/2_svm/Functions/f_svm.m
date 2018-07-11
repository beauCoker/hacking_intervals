function [lambdastar, lambda0star, alpha, primal]=f_svm(V, y, C)
%% Calculates SVM
%
%Input (see Parameters):
%   V: Features
%   y: Labels {-1,+1}
%   C: Regularization tradeoff
%Output:
%   lambdastar: hyperplane
%   lambda0star: intercept term
%   alpha: dual variables
%   primal: value of primal function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Precalculate
[n, ~] = size(V);
M = y.*V;
H = M*M';

%% Solve Dual
% Use quadprog
f = -ones(n,1);

Aeq = y';
beq = 0;

lb = zeros(n,1);
ub = C*ones(n,1);

[alpha, dual_val] = quadprog(H,f,[],[],Aeq,beq,lb,ub); % This is MUCH slower than fitcsvm...

%% Back out primal solution
% lambda
lambdastar = V'*(alpha.*y);

% lambda0
r=C-alpha;
[~,i_sv1] = min(abs(alpha-r)); % Support vector with margin 1
lambda0star = y(i_sv1) - V(i_sv1,:) * lambdastar;

% Old way:
%idx = find(r > .001 & alpha > .001); % Support vectors with margin = 1, I think
%lambda0star_all = y(idx) - V(idx,:) * lambdastar;
%lambda0star = max(lambda0star_all);

%% Find primal value (for setting theta)
primal = 1/2*(lambdastar'*lambdastar) + C*sum(max(0,1-y.*(V*lambdastar+lambda0star)));

