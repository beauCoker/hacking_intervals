clear

folder_home = '../../../';
folder_in = [folder_home 'Data/3_setup_newfeature/'];
folder_out = [folder_home 'Results/newfeature/'];

%%
load([folder_in 'newfeature_input_old.mat'])

X = data(:,1:end-1);
y = data(:,end);

T_name = 'sex_Male'; %Column name of "treatment" variable
T_id = strcmp(T_name, data_names);

%%
b = glmfit(X,y,'binomial','link','logit');

ORyxc = exp(b(T_id));

%
n = 100;
ORyu0 = [1.1,1.4];
d = .1;

c = linspace(.1,.3,n+1);

ORyxcu_min = nan(n+1,length(ORyu0));
ORyxcu_max = nan(n+1,length(ORyu0));

for i=1:length(ORyu0)
    AF_min = 1-(ORyu0(i) - 1).*c ./ ((ORyu0(i) - 1)*d + 1);
    AF_max = 1+(ORyu0(i) - 1).*c ./ ((ORyu0(i) - 1)*d + 1);
    
    ORyxcu_min(:,i) = ORyxc ./ AF_max';
    ORyxcu_max(:,i) = ORyxc ./ AF_min';
    
end


fig1 = figure;
pal = [0 0 0;0 0 1 ];
hold on
plot(c, ORyxcu_min(:,1), 'LineStyle','--','LineWidth',1.5, 'color',pal(1,:))
plot(c, ORyxcu_min(:,2), 'LineStyle','--','LineWidth',1.5, 'color',pal(2,:))

plot(c, ORyxcu_max(:,1), 'LineStyle','--','LineWidth',1.5, 'color',pal(1,:))
plot(c, ORyxcu_max(:,2), 'LineStyle','--','LineWidth',1.5, 'color',pal(2,:))

text(.2,1.33,'OR_{YU}=1.1','color',pal(1,:))
text(.2,1.41,'OR_{YU}=1.4','color',pal(2,:))

ylabel('OR_{YT|XU}')
xlabel('c')
hold off

%saveas(fig1, [folder_out 'odds_ratio.png'])
