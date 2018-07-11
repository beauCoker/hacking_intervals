function [f, grad, Hess] = f_dual_obj(x, M, H, xnew, theta, s)
%% Dual objective function for SVM hacking interval
%
%Input (see Parameters):
%   x: Dual variables (last one is beta, rest are alpha)
%   M: label*features
%   H: outer product of M
%   xnew: Observation on which to calculate hacking interval
%   theta: Loss constraint
%   s: Switches between hacking min/max problem (-1=max,+1=min) 
%Output:
%   f: Function value
%   grad: Gradient
%   Hess: Hession matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

alpha = x(1:end-1);
beta = x(end);

term1 = xnew'*xnew - 2*s*(M*xnew)'*alpha + alpha'*H*alpha;

% Calculate objective f
f = 1/(2*beta)*term1 - sum(alpha) + beta*theta;

if nargout > 1 % gradient required
    term2 = -2*s*(M*xnew) + 2*H*alpha;
    grad = [1/(2*beta)*term2 - ones(length(alpha),1);
        -1/(2*beta^2)*term1+theta];
 
    if nargout > 2 % Hessian required
        % For fmincon, only trust-region-reflective uses the Hessian. But
        % this algorithm can only handle bounds or linear equality
        % constraints, so it won't work for the svm dual.
        
        %Hess_11 = 1/beta * diag(H);
        %Hess_22 = 1/(beta^3) * term1;
        %Hess_21 = -1/(2*beta^2) * term2;
        %Hess = [Hess_11 Hess_21'; Hess_21 Hess_22];
    end

end