%%%%%%%%%%%%%%%%%%%% Generate data
clear
close all
rng(839);

n=500;
sig2 = 1;
T=(rand(n,1)>.5); % determine who is treated
C=1-T; % determine who is control
V1=rand(n,1).*4+1; % range of x.1 between 1 and 5
V2=rand(n,1).*4+1; % range of x.2 between 1 and 5
epsilon=normrnd(0,sig2,n,1);
y=2*T+V1+V2+ epsilon; % simulated outcomes
x = [V1, V2, V1.^2, V2.^2, V1.*V2, V1.*(V2.^2), (V1.^2).*V2, ...
    (V1.^2).*(V2.^2), ones(n,1)];

% keep track of the indices of the treatment and control points so we can do separate regressions.
xC=x(find(C),:);
xT=x(find(T),:);
yC=y(find(C));
yT=y(find(T));

%%%%%%%%%%%%%%%%%%% Location of xnew
V1new=3; V2new=2;
xnew=[V1new, V2new, V1new.^2, V2new.^2, V1new.*V2new, V1new.*(V2new.^2), ...
   (V1new.^2).*V2new, (V1new.^2).*(V2new.^2), 1];

%%%%%%%%%*************************************
%%%%%%%%%%% Here's the algorithm
invmatT=inv(transpose(xT)*xT);
invmatC=inv(transpose(xC)*xC);
betaLST=invmatT*(transpose(xT)*yT);
betaLSC=invmatC*(transpose(xC)*yC);

% Let's set theta to be 10 percent higher than the least square loss. The user should ust this based on desired level of robustness to fiddling
thetaT = sum((yT-xT*betaLST).^2)*1.1;
thetaC = sum((yC-xC*betaLSC).^2)*1.1;

%%%%% Call the function rangefunc to get the beta's.
[betaminT,betamaxT]=rangefunc(xT,yT,xnew,thetaT);
[betaminC,betamaxC]=rangefunc(xC,yC,xnew,thetaC);
t1xnew=xnew*betamaxT;
t2xnew=xnew*betaminT;
c1xnew=xnew*betamaxC;
c2xnew=xnew*betaminC;
[t1xnew,t2xnew,c1xnew,c2xnew]
% range of treatment effects is:
maxeffect=max(t1xnew,t2xnew)-min(c1xnew,c2xnew)
mineffect=min(t1xnew,t2xnew)-max(c1xnew,c2xnew)
%%%%%%%%%*************************************

%%%%%%%%%%%%%%%%% Plot the result
V1plot=[1:.1:5]';
V2plot=[1:.1:5]';
for i=1:length(V1plot)
for k=1:length(V2plot)
xx = [V1plot(i), V2plot(k), V1plot(i).^2, V2plot(k).^2, ...
    V1plot(i).*V2plot(k), V1plot(i).*(V2plot(k).^2), ...
    (V1plot(i).^2).*V2plot(k), (V1plot(i).^2).*(V2plot(k).^2),1];
zuntreatedmax(i,k)=xx*betamaxC;
zuntreatedmin(i,k)=xx*betaminC;
ztreatedmax(i,k)=xx*betamaxT;
ztreatedmin(i,k)=xx*betaminT;
end
end
xxnew= [V1new, V2new, V1new.^2, V2new.^2, V1new.*V2new, ...
   V1new.*(V2new.^2), (V1new.^2).*V2new, (V1new.^2).*(V2new.^2),1];

FontSize = 22;

% All four curves
figure(1)
surf(V1plot,V2plot,zuntreatedmax')
hold on
surf(V1plot,V2plot,ztreatedmin')
plot3([V1new,V1new]',[V2new,V2new]', [xxnew*betamaxC,xxnew*betaminT]','Linewidth',10);

surf(V1plot,V2plot,zuntreatedmin')
surf(V1plot,V2plot,ztreatedmax')
plot3([V1new,V1new]',[V2new,V2new]',[xxnew*betaminC,xxnew*betamaxT]','Linewidth',10);                              

xlabel('$$v_{\cdot 1}^{\textrm{new}}$$','Interpreter','Latex')
ylabel('$$v_{\cdot 2}^{\textrm{new}}$$','Interpreter','Latex')
zlabel('$$\hat{y}$$','Interpreter','Latex')
xlim([1 5])
ylim([1 5])
set(gca, 'FontSize', FontSize)

% Max effect
figure(2) 
surf(V1plot,V2plot,zuntreatedmin')
hold on
surf(V1plot,V2plot,ztreatedmax')
plot3([V1new,V1new]',[V2new,V2new]',[xxnew*betaminC,xxnew*betamaxT]','Linewidth',10);                              

xlabel('$$v_{\cdot 1}^{\textrm{new}}$$','Interpreter','Latex')
ylabel('$$v_{\cdot 2}^{\textrm{new}}$$','Interpreter','Latex')
zlabel('$$\hat{y}$$','Interpreter','Latex')
xlim([1 5])
ylim([1 5])
set(gca, 'FontSize', FontSize)
      

% Min effect
figure(3)
surf(V1plot,V2plot,zuntreatedmax')
hold on
surf(V1plot,V2plot,ztreatedmin')
plot3([V1new,V1new]',[V2new,V2new]', [xxnew*betamaxC,xxnew*betaminT]','Linewidth',10);

xlabel('$$v_{\cdot 1}^{\textrm{new}}$$','Interpreter','Latex')
ylabel('$$v_{\cdot 2}^{\textrm{new}}$$','Interpreter','Latex')
zlabel('$$\hat{y}$$','Interpreter','Latex')
xlim([1 5])
ylim([1 5])
set(gca, 'FontSize', FontSize)