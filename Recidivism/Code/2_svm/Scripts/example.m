%% Generates example figure for SVM hacking

clear
close all

% Add functions to search path
addpath('../Functions')

%% Generate sample data
rng(192);

% Same as regression example
n=500;
T=(rand(n,1)>.5); 
V1=rand(n,1).*4+1; % range of x.1 between 1 and 5
V2=rand(n,1).*4+1; % range of x.2 between 1 and 5
V = [V1 V2];

epsilon=randn(n,1);
y=2*T+V1+V2+ epsilon; % simulated outcomes

% Convert y binary variable
y = double(y>mean(y));
y(y==1)= -1;
y(y==0)= 1;

%% Run SVM

C = 1;

[lambdastar_svm, lambda0star_svm, alpha_svm, primal_svm]=f_svm(V, y, C);

%% Calculate hacking interval

xnew = [3; 2];
theta = 1.05 * primal_svm;

[effect_min, effect_max, ...
    effect_geo_min, effect_geo_max, ...
    flag_min, flag_max, ...
    lambdastar_min, lambda0star_min, ...
    lambdastar_max, lambda0star_max]=f_svm_hacked(V, y, C, theta, xnew, [alpha_svm; .05]);

%% Hyperplane figure

close all
figure();

idpos = y==1;
idneg = y==-1;

subplot(1,2,1);

hold on
scatter(V1(idpos),V2(idpos),10,'MarkerEdgeColor','r','MarkerEdgeAlpha',.3,'Marker','+')
scatter(V1(idneg),V2(idneg),10,'MarkerEdgeColor','b','MarkerEdgeAlpha',.3,'Marker','o')

% xnew
scatter(xnew(1),xnew(2),100,[1 0 1],'r+','LineWidth',2)

% SVM
plot(V1, -V1*lambdastar_svm(1)/lambdastar_svm(2)-lambda0star_svm/lambdastar_svm(2), 'linewidth',2,'color','black')
arrow_scale = .3;
p1x = 3;
p1y = -p1x*lambdastar_svm(1)/lambdastar_svm(2)-lambda0star_svm/lambdastar_svm(2);

lsvm = lambdastar_svm/norm(lambdastar_svm);
l0svm = lambda0star_svm/norm(lambdastar_svm);

ssvm = (lsvm'*xnew + l0svm);
u = lsvm(1)*ssvm;
v = lsvm(2)*ssvm;
px = xnew(1) - u;
py = xnew(2) - v;

quiver(px,py,u,v,...
    'linewidth',2,'color','black','MaxHeadSize',0,'LineStyle',':')


% Min
plot(V1, -V1*lambdastar_min(1)/lambdastar_min(2)-lambda0star_min/lambdastar_min(2), 'linewidth',2,'color',[0.0556,0.6966,0.2479])
p1x = 3;
p1y = -p1x*lambdastar_min(1)/lambdastar_min(2)-lambda0star_min/lambdastar_min(2);

lmin = lambdastar_min/norm(lambdastar_min);
l0min = lambda0star_min/norm(lambdastar_min);

smin = (lmin'*xnew + l0min);
u = lmin(1)*smin;
v = lmin(2)*smin;
px = xnew(1) - u;
py = xnew(2) - v;

quiver(px,py,u,v,...
    'linewidth',2,'color',[0.0556,0.6966,0.2479],'MaxHeadSize',0,'LineStyle',':')

% Max
plot(V1, -V1*lambdastar_max(1)/lambdastar_max(2)-lambda0star_max/lambdastar_max(2), 'linewidth',2, 'color','m')
p1x = 3;
p1y = -p1x*lambdastar_max(1)/lambdastar_max(2)-lambda0star_max/lambdastar_max(2);

lmax = lambdastar_max/norm(lambdastar_max);
l0max = lambda0star_max/norm(lambdastar_max);

smax = (lmax'*xnew + l0max);
u = lmax(1)*smax;
v = lmax(2)*smax;
px = xnew(1) - u;
py = xnew(2) - v;

quiver(px,py,u,v,...
    'linewidth',2,'color','m','MaxHeadSize',0,'LineStyle',':')

% Text
text(3.6,2.33,'Min Loss','FontSize',10,'Rotation',atan(-lsvm(1)/lsvm(2))*360/(2*pi));
text(3.35,2.1,'Hacking LB','color',[0.0556,0.6966,0.2479],'FontSize',10,'Rotation',atan(-lmin(1)/lmin(2))*360/(2*pi))
text(3.9,2.75,'Hacking UB','color','m','FontSize',10,'Rotation',atan(-lmax(1)/lmax(2))*360/(2*pi))

text(xnew(1)-.25,xnew(2)-.25,'x^{(new)}','color','r','FontSize',10)

% Axes and scale
axis([1 5 1 5])
axis square

ylabel('x_{2}')
xlabel('x_{1}')

set(gca,'xtick',[1:5],'ytick',[1:5])

hold off

%% Hacking interval figure
subplot(1,2,2)

effect_svm = (lambdastar_svm'*xnew + lambda0star_svm)/norm(lambdastar_svm);

errorbar(0.25,effect_svm, effect_svm - effect_min, effect_max - effect_svm,'-s','linewidth',2,'color','b') 
text(.06,effect_max+.1,'Hacking Interval','FontSize',10,'color','b')

hold on
plot([.5,.5],[0,effect_max],'linewidth',2, 'LineStyle',':','color','m')
text(.52,effect_max,'Hacking UB','color','m','FontSize',10)

plot([.55,.55],[0,effect_svm],'linewidth',2, 'LineStyle',':','color','k')
text(.57,effect_svm,'Min Loss','color','k','FontSize',10)

plot([.6,.6],[0,effect_min],'linewidth',2, 'LineStyle',':','color',[0.0556,0.6966,0.2479])
text(.62,effect_min,'Hacking LB','color',[0.0556,0.6966,0.2479],'FontSize',10)

axis([0 1 0, 2])
axis square

set(gca,'XTickLabel',[],'xtick',[])

ylabel('Scaled Distance to Hyperplane')
hold off

