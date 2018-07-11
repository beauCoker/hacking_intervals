clear
close all

folder_home = '../../../';
folder_in = [folder_home 'Data/3_setup_newfeature/'];
folder_out = [folder_home 'Results/newfeature/'];

%%
load([folder_in 'newfeature_input.mat'])

X = data(:,1:end-1);
y = data(:,end);

T_name = 'sex_Male'; %Column name of "treatment" variable
T_id = strcmp(T_name, data_names);

%% Calculate ORyxc
b = glmfit(X,y,'binomial','link','logit');

ORyxc = exp(b(T_id));

% Choose values of ORyu0, c, and d
ORyu0 = [1.5,1.75];
c = [.1:.05:.3];
d = .1;

% Find the optimal adjustment factor for each choice
n = length(c)-1;
ORyxcu_min = nan(n+1,length(ORyu0));
ORyxcu_max = nan(n+1,length(ORyu0));

for i=1:length(ORyu0)
    AF_min = 1-(ORyu0(i) - 1).*c ./ ((ORyu0(i) - 1)*d + 1);
    AF_max = 1+(ORyu0(i) - 1).*c ./ ((ORyu0(i) - 1)*d + 1);
    
    % Difference between these is the hacking interval
    ORyxcu_min(:,i) = ORyxc ./ AF_max';
    ORyxcu_max(:,i) = ORyxc ./ AF_min';
    
end

%% Figure
fig1 = figure;

FontSize = 16;

pal = [0 0 0;0 0 1 ];
hold on
dx = [1 -1]*.0025;
for i = 1:2
    mid = (ORyxcu_min(:,i) + ORyxcu_max(:,i))/2;
    err = ORyxcu_max(:,i) - ORyxcu_min(:,i);
    errorbar(c+dx(i), mid, err/2, 'color', pal(i,:), 'LineStyle','none','linewidth',2)
end

text(.3075,1.24,'OR_{yu}=1.5','color',pal(1,:),'FontSize',FontSize)
text(.3025,1.46,'OR_{yu}=1.75','color',pal(2,:),'FontSize',FontSize)

xticks(c)
xlabel('c','Interpreter','Latex')
ylabel('OR_{yw|xu}')

set(gca, 'FontSize', FontSize)

hold off

saveas(fig1, [folder_out 'odds_ratio.pdf'])
