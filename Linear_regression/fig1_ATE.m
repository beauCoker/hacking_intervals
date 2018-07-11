%%%%%%%%%%%% Create the dataset
clear
close all
rng(839);

center_X = false;

n=500;
sig2 = 1;
T=(rand(n,1)>.5); % determines whether a point is treatment or control
V1=rand(n,1).*4+1; % all of the x.1 values are between 1 and 5
V2=rand(n,1).*4+1; % all of the x.2 values are between 1 and 5
epsilon=normrnd(0,sig2,n,1);
Y=2*T+V1+V2+epsilon; %this is the truth from which the outcomes are generated, including noise
% the x vectors include monomial terms
X = [ones(n,1), V1, V2, V1.^2, V2.^2, V1.*V2, V1.*(V2.^2), (V1.^2).*V2, ...
    (V1.^2).*(V2.^2)];
p = size(X,2)-1;
% Now we have X and Y and treatment indicator T.

%%%%%%%%%%%%%%%%% Pick a sane value for theta
% Define terms for later use:
Xt=[X,T];

if center_X
    % Remove column means:
    meanX = [0, mean(X(:,2:end))];
    meanXt = [0, mean(Xt(:,2:end))];
    
    X = X - repmat(meanX,n,1);
    Xt = Xt - repmat(meanXt,n,1);
    T = T - mean(T);
end

invmatt=inv(transpose(Xt)*Xt);
betaLSt=invmatt*(transpose(Xt)*Y); % least squares beta, without treatment indicator %Beau: You mean WITH the treatment indicator?

% Let's set theta to be 10 percent higher than the least square loss. The user should adjust this based on desired level of robustness to fiddling
theta= sum((Y-Xt*betaLSt).^2)*1.1;

%%%%%%%%%*************************************
%%%%%%%%%%% Here's the algorithm
invmat=inv(transpose(X)*X);
betaLS=invmat*transpose(X)*Y; % least squares beta, without treatment indicator
d=Y-X*betaLS; % define d
hh=invmat*transpose(X)*T; % part of h
h=X*hh-T; % define h

%% Define the three terms for the quadratic formula:
a=sum(h.^2);
b=2*transpose(h)*d;
c=sum(d.^2) - theta;

%%%%%%%%%%%%%%%% Solutions:
beta0max= (-b + sqrt(b^2-(4*a*c)))/(2*a);
beta0min= (-b - sqrt(b^2-(4*a*c)))/(2*a);
betamax=betaLS-beta0max*hh;
betamin=betaLS-beta0min*hh;
%%%%%%%%%*************************************

%%%%%%%%%%%%%%%% Plot the result
V1plot=[1:.1:5]';
V2plot=[1:.1:5]';
for i=1:length(V1plot)
    for k=1:length(V2plot)
 
        xx = [1, V1plot(i), V2plot(k), V1plot(i).^2, V2plot(k).^2, ...
            V1plot(i).*V2plot(k), V1plot(i).*(V2plot(k).^2), ...
            (V1plot(i).^2).*V2plot(k), (V1plot(i).^2).*(V2plot(k).^2)];
        if center_X
            xx = xx - meanX;
        end
        
        zuntreatedmax(i,k)=xx*betamax;
        zuntreatedmin(i,k)=xx*betamin;
        ztreatedmax(i,k)=xx*betamax + beta0max;
        ztreatedmin(i,k)=xx*betamin + beta0min;
    end
end

FontSize = 22;

% All four curves
figure(1)
surf(V1plot,V2plot,ztreatedmax) % 4
hold on
surf(V1plot,V2plot,ztreatedmin) % 3
surf(V1plot,V2plot,zuntreatedmin) % 2
surf(V1plot,V2plot,zuntreatedmax) % 1
xlabel('$$v_{\cdot 1}^{\textrm{new}}$$','Interpreter','Latex')
ylabel('$$v_{\cdot 2}^{\textrm{new}}$$','Interpreter','Latex')
zlabel('$$\hat{y}$$','Interpreter','Latex')
xlim([1 5])
ylim([1 5])
set(gca, 'FontSize', FontSize)

% Max only
figure(2)
surf(V1plot,V2plot,ztreatedmax)
hold on
surf(V1plot,V2plot,zuntreatedmax)
xlabel('$$v_{\cdot 1}^{\textrm{new}}$$','Interpreter','Latex')
ylabel('$$v_{\cdot 2}^{\textrm{new}}$$','Interpreter','Latex')
zlabel('$$\hat{y}$$','Interpreter','Latex')
xlim([1 5])
ylim([1 5])
set(gca, 'FontSize', FontSize)

% Min only
figure(3)
surf(V1plot,V2plot,ztreatedmin) 
hold on 
surf(V1plot,V2plot,zuntreatedmin)
xlabel('$$v_{\cdot 1}^{\textrm{new}}$$','Interpreter','Latex')
ylabel('$$v_{\cdot 2}^{\textrm{new}}$$','Interpreter','Latex')
zlabel('$$\hat{y}$$','Interpreter','Latex')
xlim([1 5])
ylim([1 5])
set(gca, 'FontSize', FontSize)

%%%%%% Sanity checks:
% Check theta
theta
sum((Y-Xt*[betamax;beta0max]).^2) %%% this should be the same as theta
sum((Y-Xt*[betamin;beta0min]).^2) %%% this should be the same as theta

% Check beta0min and beta0max from Corollary
SSE = sum((Y-Xt*betaLSt).^2);
V = inv(transpose(Xt)*Xt);
Vtt = V(end,end);

beta0min
beta0max

betaLSt(end) - sqrt(Vtt)*sqrt(theta - SSE) %%% this should be the same as beta0min
betaLSt(end) + sqrt(Vtt)*sqrt(theta - SSE) %%% this should be the same as beta0max