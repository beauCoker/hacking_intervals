close all

%% For single threshold

% Krzanowski method
tol_D = 0.02; 

[D_best, i_D_best] = min(D);
D_select = find(C(i_D_best,:)); % Variables selected

i_D_ok = find(D < (1+tol_D) * D_best);
i_D_ok = setdiff(i_D_ok,i_D_best); % Take out the best one

hamming_D = sum(C(i_D_best,:) ~=  C(i_D_ok,:),2); 

D_select_superset = any(C(i_D_ok,:),1);

% Guo et al. method
tol_V_diff = 2;

[V_diff_best, i_V_diff_best] = min(V_diff);
V_select = find(C(i_V_diff_best,:)); % Variables selected

i_V_ok = find( V_diff <= V_diff_best + tol_V_diff);
i_V_ok = setdiff(i_V_ok,i_V_diff_best); % Take out the best one

hamming_V = sum(C(i_V_diff_best,:) ~=  C(i_V_ok,:),2); % 

V_select_superset = any(C(i_V_ok,:),1);

% Histogram
figure
histogram(hamming_V)
title('Histogram of Hamming distances in variables chosen')
xlabel('Hamming distance')
ylabel('Count')

%% Compute a few things for expanding Rashomon sets
% Use Guo et al. method

% Tolerances to try
vtol = 0:.001:10;

% Allocate space
i_ok_list = cell(length(vtol),1);
select_superset_list = cell(length(vtol),1);
hamming_list = cell(length(vtol),1);

for i = 1:length(vtol)
    i_ok_list{i} = find( V_diff <= V_diff_best + vtol(i)); % Index of subsets within tolerance
    select_superset_list{i} = any(C(i_ok_list{i},:),1); % If variable is included in any subset within tolerance
    hamming_list{i} = sum(C(i_V_diff_best,:) ~=  C(i_ok_list{i},:),2); % Hamming of each subset within tolerance to best subset
end

n_subsets = cellfun(@length, i_ok_list);
n_vars = cellfun(@sum, select_superset_list);
max_hamming = cell2mat(cellfun(@max, hamming_list, 'UniformOutput',false));

%% Figures

figure
% Number of 4-variable subsets for which there exists a subset within
% threshold for which that subset is included
subplot(1,3,1)
plot(vtol, n_subsets, 'LineWidth', 2)
ylim([0 n_subsets_max])
xlabel('$\theta''$','Interpreter','latex')
ylabel('Number of 4-feature subsets')

% Number of variables for which there exists a subset within threshold
% for which that variable is included
subplot(1,3,2)
plot(vtol, n_vars, 'LineWidth', 2)
xlim([0 2])
ylim([0 p])
xlabel('$\theta''$','Interpreter','latex')
ylabel('Number of features')

% Max Hamming distance for any subset within threshold
subplot(1,3,3)
plot(vtol, max_hamming, 'LineWidth', 2)
xlim([0 1])
ylim([0 2*q])
xlabel('$\theta''$','Interpreter','latex')
ylabel('Max Hamming distance')

%% Other stats

% Number of subsets within tolerance
sum(V_diff <= V_diff_best + 7.65)/n_subsets_max

% Tolerance needed for all variables
vtol(find(n_vars==p,1))

% Tolerance needed for all variables
vtol(find(max_hamming==2*q,1))

%% Variable selected by other methods (hardcoded)
other_methods = unique([13, 17, 11, 5, 13, 12, 17, 5, 10, 11, 17, 19, 9, 11, 17, 19, 5, 8, 11, 14, 5, 11, 13, 17, 9, 11, 17, 19, 5, 9, 11, 18, 6, 11, 17, 19, 5, 8, 11, 18, 5, 12, 14, 18, 18, 8, 11, 5, 3, 4, 14, 16, 3, 4, 14, 16]);
setdiff(1:19,other_methods)

